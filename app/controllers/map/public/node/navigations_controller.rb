require 'will_paginate/array'
class Map::Public::Node::NavigationsController < Map::Public::NodeController
  skip_after_action :render_public_layout, only: [:file_content]

  def pre_dispatch
    @node = Page.current_node
    @content = Map::Content::Marker.find(@node.content_id)
  end

  def index
    markers = @content.public_markers

    doc_markers = @content.marker_docs
                          .preload(:marker_categories, :files, :marker_icon_category)
                          .flat_map { |doc| Map::Marker.from_doc(doc) }
                          .compact

    @markers = @content.sort_markers(markers + doc_markers)
  end
end
