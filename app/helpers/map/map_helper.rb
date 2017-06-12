module Map::MapHelper
  def marker_image(marker)
    if (doc = marker.doc) && doc.content.public_node
      GpArticle::Public::DocFormatService.new(doc).format("@image_tag@")
    elsif (file = marker.files.first) && file.parent.content.public_node
      image_tag("#{file.parent.content.public_node.public_uri}#{file.parent.name}/file_contents/#{url_encode file.name}")
    end
  end
end
