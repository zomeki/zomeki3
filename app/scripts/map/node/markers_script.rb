class Map::Node::MarkersScript < PublicationScript
  def publish
    publish_more(@node, uri: @node.public_uri,
                        path: @node.public_path,
                        smart_phone_path: @node.public_smart_phone_path)

    @node.content.public_categories.each do |top_category|
      top_category.public_descendants.each do |category|
        escaped_category = "#{category.category_type.name}/#{category.path_from_root_category}".gsub('/', '@')
        file = "index_#{escaped_category}"
        publish_more(@node, uri: @node.public_uri,
                            path: @node.public_path,
                            smart_phone_path: @node.public_smart_phone_path,
                            file: file, dependent: file)
      end
    end

    @node.content.public_markers.each(&:publish_files)
    @node.content.markers.where.not(state: 'public').each(&:close_files)
  end
end
