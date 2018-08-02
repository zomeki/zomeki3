class GpCalendar::Public::Piece::CategoryDailyLinksController < GpCalendar::Public::PieceController
  def pre_dispatch
    @piece = GpCalendar::Piece::CategoryDailyLink.find(Page.current_piece.id)
    @content = @piece.content
    @item = Page.current_item
  end

  def index
    date     = params[:gp_calendar_event_date]
    min_date = params[:gp_calendar_event_min_date]
    max_date = params[:gp_calendar_event_max_date]

    unless date
      date = Date.today
      min_date = 1.year.ago(date.beginning_of_month)
      max_date = 11.months.since(date.beginning_of_month)
    end

    start_date = date.beginning_of_month.beginning_of_week(:sunday)
    end_date = date.end_of_month.end_of_week(:sunday)

    @calendar = Util::Date::Calendar.new(date.year, date.month)
    @calendar.set_event_class = true

    return unless (@node = @piece.target_node)

    @calendar.day_uri = "#{@node.public_uri}?start_date=:year-:month-:day&end_date=:year-:month-:day"

    events = @content.public_events.scheduled_between(start_date, end_date)
    events = events.categorized_into(@piece.category_ids) if @piece.category_ids.present?
    event_dates = events.flat_map { |event| to_dates(event, start_date, end_date) }.uniq

    docs = @content.event_docs.scheduled_between(start_date, end_date)
    docs = docs.categorized_into(@piece.category_ids) if @piece.category_ids.present?
    doc_dates = docs.flat_map { |doc| to_dates(doc, start_date, end_date) }.uniq

    @calendar.day_link = (event_dates | doc_dates).sort
  end

  private

  def to_dates(event, start_date, end_date)
    range = start_date..end_date
    event.periods.inject([]) do |dates, period|
      period_range = period.started_on..period.ended_on
      dates |= (range.to_a & period_range.to_a)
    end
  end
end
