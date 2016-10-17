class BizCalendar::Script::PlacesController < Cms::Controller::Script::Publication
  def publish
    info_log 'BizCalendar::Script::PlacesController#publish'
    render plain: 'OK'
  rescue => e
    error_log e.message
    render plain: e.message
  end
end
