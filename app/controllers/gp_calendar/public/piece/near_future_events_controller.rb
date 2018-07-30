class GpCalendar::Public::Piece::NearFutureEventsController < GpCalendar::Public::PieceController
  def pre_dispatch
    @piece = GpCalendar::Piece::NearFutureEvent.find(Page.current_piece.id)
    @content = @piece.content
    @item = Page.current_item
  end

  def index
    @today = Date.today
    @tomorrow = Date.tomorrow

    events = @content.public_events
    todays_events = events.scheduled_on(@today)
    tomorrows_events = events.scheduled_on(@tomorrow)

    docs = @content.event_docs
    todays_docs = docs.event_scheduled_on(@today)
    tomorrows_docs = docs.event_scheduled_on(@tomorrow)

    @todays_events = merge_events_and_docs(@content, todays_events, todays_docs)
    @tomorrows_events = merge_events_and_docs(@content, tomorrows_events, tomorrows_docs)
  end
end
