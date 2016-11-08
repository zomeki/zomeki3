class BizCalendar::Script::PlacesController < Cms::Controller::Script::Publication
  def publish
    info_log 'BizCalendar::Script::PlacesController#publish'
    @node.content.places.public_state.each do |place|
      mi_uri = place.public_uri
      mi_path = place.public_path
      mi_smart_phone_path = place.public_smart_phone_path
      publish_page(@node, uri: mi_uri, path: mi_path, smart_phone_path: mi_smart_phone_path, dependent: mi_uri)
    end

    render plain: 'OK'
  rescue => e
    error_log e.message
    render plain: e.message
  end
end
