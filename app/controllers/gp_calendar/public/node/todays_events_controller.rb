class GpCalendar::Public::Node::TodaysEventsController < GpCalendar::Public::NodeController
  def index
    http_error(404) if params[:page]

    events = @content.public_events.scheduled_on(@today)
    docs = @content.event_docs.event_scheduled_on(@today)

    @events = merge_events_and_docs(@content, events, docs)

    @holidays = @content.public_holidays.scheduled_on(@today)
  end
end
