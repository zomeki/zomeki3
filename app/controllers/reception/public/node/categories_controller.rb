class Reception::Public::Node::CategoriesController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = Reception::Content::Course.find(@node.content_id)

    @category_type = @content.category_types.find_by!(name: params[:category_type_name])
    @category = @category_type.find_category_by_path_from_root_category(params[:category_names])
    return http_error(404) unless @category.try(:public?)

    Page.current_item = @category.becomes(Reception::Category) # becomes for bread crumbs
    Page.title = @category.title
  end

  def index
    @courses = @content.public_courses.categorized_into(@category.public_descendants)
                       .order(sort_no: :asc, id: :asc)
  end
end
