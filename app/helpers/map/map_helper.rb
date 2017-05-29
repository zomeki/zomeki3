module Map::MapHelper
  def default_lat_lng
    if @content.default_map_position.blank?
      if @markers.empty?
        [0, 0]
      else
        [@markers.first.latitude, @markers.first.longitude]
      end
    else
      @content.default_map_position
    end
  end

  def default_latitude
    default_lat_lng.first
  end

  def default_longitude
    default_lat_lng.last
  end

  def marker_image(marker)
    if (doc = marker.doc) && doc.content.public_node
      GpArticle::Public::DocFormatService.new(doc).format("@image_tag@")
    elsif (file = marker.files.first) && file.parent.content.public_node
      image_tag("#{file.parent.content.public_node.public_uri}#{file.parent.name}/file_contents/#{url_encode file.name}")
    end
  end
end
