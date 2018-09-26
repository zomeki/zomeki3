class GpCalendar::Public::Node::TodaysEventsController < GpCalendar::Public::NodeController
  def index
    http_error(404) if params[:page]

    @range = [@today, @today]

    events = @content.public_events.scheduled_on(@today)
    docs = @content.event_docs.scheduled_on(@today)

    @events = GpCalendar::EventMergeService.new(@content).merge(events, docs, @range)

    @holidays = @content.public_holidays.scheduled_on(@today)
  end
end
