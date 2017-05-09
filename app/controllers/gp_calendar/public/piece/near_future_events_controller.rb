class GpCalendar::Public::Piece::NearFutureEventsController < GpCalendar::Public::Piece::BaseController
  def pre_dispatch
    @piece = GpCalendar::Piece::NearFutureEvent.find_by(id: Page.current_piece.id)
    return render(:text => '') unless @piece

    @item = Page.current_item
  end

  def index
    today = Date.today
    tomorrow = today.tomorrow

    events = @piece.content.events.public_state.scheduled_between(today, tomorrow)
    @todays_events = events.select {|ev| ev.started_on <= today && today <= ev.ended_on }
    @tomorrows_events = events.select {|ev| ev.started_on <= tomorrow && tomorrow <= ev.ended_on }

    docs = @piece.content.public_event_docs(today, tomorrow)
    today_docs = docs.event_scheduled_between(today, today)
    tomorrow_docs = docs.event_scheduled_between(tomorrow, tomorrow)

    @todays_events = merge_docs_into_events(today_docs, @todays_events)
    @tomorrows_events = merge_docs_into_events(tomorrow_docs, @tomorrows_events)
  end
end
