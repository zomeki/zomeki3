require 'will_paginate/array'
class Map::Public::Node::MarkersController < Map::Public::NodeController
  skip_after_action :render_public_layout, only: [:file_content]

  def pre_dispatch
    @node = Page.current_node
    @content = Map::Content::Marker.find(@node.content_id)

    @specified_category = find_category_by_specified_path(@content, params[:escaped_category])
    Page.title += " #{@specified_category.title}" if @specified_category
  end

  def index
    markers = @content.public_markers
    markers = markers.categorized_into(@specified_category.public_descendants) if @specified_category

    docs = @content.marker_docs
    docs = docs.categorized_into(@specified_category.public_descendants, categorized_as: 'Map::Marker') if @specified_category
    doc_markers = docs.preload(:marker_categories, :files, :marker_icon_category)
                      .flat_map { |doc| Map::Marker.from_doc(doc) }
                      .compact

    @all_markers = @content.sort_markers(markers + doc_markers)
    @markers = @all_markers.paginate(page: params[:page], per_page: 30)
    return http_error(404) if @markers.current_page > @markers.total_pages
    return render 'index_google' if @content.site.map_source == "google"
  end

  def file_content
    @marker = @content.markers.find_by!(name: params[:name])
    file = @marker.files.first!

    send_file file.upload_path, filename: file.name
  end

  private

  def find_category_by_specified_path(content, path)
    return if path.blank?
    category_type_name, category_path = path.gsub('@', '/').split('/', 2)
    category_type = content.category_types.find_by(name: category_type_name)
    return unless category_type
    category_type.find_category_by_path_from_root_category(category_path)
  end
end
