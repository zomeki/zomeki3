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
    todays_docs = docs.scheduled_on(@today)
    tomorrows_docs = docs.scheduled_on(@tomorrow)

    @todays_events = GpCalendar::EventMergeService.new(@content).merge(todays_events, todays_docs, [@today, @today])
    @tomorrows_events = GpCalendar::EventMergeService.new(@content).merge(tomorrows_events, tomorrows_docs, [@tomorrow, @tomorrow])
  end
end
