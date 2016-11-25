class GpCalendar::Public::Piece::EventsController < GpCalendar::Public::Piece::BaseController
  def pre_dispatch
    @piece = GpCalendar::Piece::Event.find_by(id: Page.current_piece.id)
    return render(:text => '') unless @piece
    @item = Page.current_item
  end

  def index

    start_date, end_date = case @piece.target_date
    when 'near_future'
      [Date.today, nil]
    when 'this_month'
      [Date.today.beginning_of_month, Date.today.end_of_month]
    else
      [Date.today, nil]
    end

    criteria = {categories: @piece.category_ids}
    events = GpCalendar::Event.public_state.content_and_criteria(@piece.content, criteria).order(:started_on)
      .scheduled_between(start_date, end_date)
    events = events.limit(@piece.docs_number) if @piece.docs_number
    @events =  events.preload(:categories).to_a
    merge_docs_into_events(event_docs(start_date, end_date, nil), @events)

    @events.sort! {|a, b| a.started_on <=> b.started_on}
  end
end
