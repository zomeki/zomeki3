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
      doc_image_tag(doc)
    elsif (file = marker.files.first) && file.parent.content.public_node
      image_tag("#{file.parent.content.public_node.public_uri}#{file.parent.name}/file_contents/#{url_encode file.name}")
    end
  end

  def title_replace(doc, doc_style)
    return unless doc

    contents = {
      title_link: content_tag(:span, link_to(doc.title, doc.public_uri), class: 'title_link'),
      title: content_tag(:span, doc.title, class: 'title'),
      subtitle: content_tag(:span, doc.subtitle, class: 'subtitle'),
      summary:  doc.summary,
      }

    if Page.mobile?
      contents[:title_link]
    else
      doc_style.gsub(/@\w+@/, {
        '@title_link@' => contents[:title_link],
        '@title@'    => contents[:title],
        '@subtitle@' => contents[:subtitle],
        '@summary@'  => contents[:summary],
      }).html_safe
    end
  end
end
