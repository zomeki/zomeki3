class GpCalendar::Public::Piece::EventsController < GpCalendar::Public::Piece::BaseController
  def pre_dispatch
    @piece = GpCalendar::Piece::Event.find_by(id: Page.current_piece.id)
    return render(:text => '') unless @piece
    @item = Page.current_item
  end

  def index
    @date = Date.today
    start_date, end_date = case @piece.target_date
    when 'near_future'
      [Date.today, nil]
    when 'this_month'
      [Date.today.beginning_of_month, Date.today.end_of_month]
    else
      [Date.today, nil]
    end

    criteria = {}
    events = GpCalendar::Event.public_state.content_and_criteria(@piece.content, criteria).order(:started_on)
      .scheduled_between(start_date, end_date)
    events = events.limit(@piece.docs_number) if @piece.docs_number
    @events =  events.preload(:categories).to_a

    @piece.category_ids.each do |category|
      @events.reject! {|c| c.categories && !c.categories.map{|ct| ct.id }.include?(category) }
    end

    merge_docs_into_events(event_docs(start_date, end_date, @piece.category_ids), @events)

    @events.sort! {|a, b| a.started_on <=> b.started_on}
    @events = @events.slice(0, @piece.docs_number) if @piece.docs_number
  end
end
