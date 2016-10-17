class GpCalendar::Script::TodaysEventsController < GpCalendar::Script::BaseController
  def publish
    publish_without_months
    render plain: 'OK'
  rescue => e
    error_log e.message
    render plain: e.message
  end
end
