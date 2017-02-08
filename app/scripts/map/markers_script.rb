class Map::MarkersScript < Cms::Script::Publication
  def publish
    publish_more(@node, uri: @node.public_uri,
                 path: @node.public_path, smart_phone_path: @node.public_smart_phone_path, dependent: 'more')

    @node.content.public_categories.each do |top_category|
      top_category.public_descendants.each do |category|
        escaped_category = "#{category.category_type.name}/#{category.path_from_root_category}".gsub('/', '@')
        file = "index_#{escaped_category}"

        publish_more(@node, uri: @node.public_uri, file: file,
                     path: @node.public_path, smart_phone_path: @node.public_smart_phone_path, dependent: "more_#{file}")
      end
    end

    @node.content.public_markers.each do |marker|
      file = marker.files.first
      next unless file && ::File.exist?(file.upload_path)

      Util::File.put marker.public_file_path, src: file.upload_path, mkdir: true
      if @node.content.site.publish_for_smart_phone?
        Util::File.put marker.public_smart_phone_file_path, src: file.upload_path, mkdir: true
      end
    end
  end
end
