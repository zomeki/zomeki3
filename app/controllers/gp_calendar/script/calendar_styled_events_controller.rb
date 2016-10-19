class GpCalendar::Script::CalendarStyledEventsController < GpCalendar::Script::BaseController
  def publish
    publish_with_months
    render plain: 'OK'
  rescue => e
    error_log e.message
    render plain: e.message
  end
end
