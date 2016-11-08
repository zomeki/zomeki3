class BizCalendar::Script::PlacesController < Cms::Controller::Script::Publication
  def publish
    info_log 'BizCalendar::Script::PlacesController#publish'
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s
    publish_page(@node, uri: uri, path: path, smart_phone_path: smart_phone_path, dependent: uri)

    @node.content.places.public_state.each do |place|
      p_uri = place.public_uri
      p_path = place.public_path
      p_smart_phone_path = place.public_smart_phone_path
      publish_page(@node, uri: p_uri, path: p_path, smart_phone_path: p_smart_phone_path, dependent: p_uri)
    end

    render plain: 'OK'
  rescue => e
    error_log e.message
    render plain: e.message
  end
end
