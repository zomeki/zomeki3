class GpCalendar::Public::Piece::EventsController < GpCalendar::Public::PieceController
  def pre_dispatch
    @piece = GpCalendar::Piece::Event.find(Page.current_piece.id)
    @content = @piece.content
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

    events = @content.public_events.scheduled_between(start_date, end_date)
    events = events.categorized_into(@piece.category_ids) if @piece.category_ids.present?
    events = events.order(:started_on).preload(:categories).to_a

    docs = @piece.content.event_docs.event_scheduled_between(start_date, end_date)
    docs = docs.categorized_into(@piece.category_ids) if @piece.category_ids.present?

    @events = merge_events_and_docs(@content, events, docs)
    @events = @events.slice(0, @piece.docs_number) if @piece.docs_number
  end
end
