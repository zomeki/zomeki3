class GpCalendar::Public::Piece::DailyLinksController < GpCalendar::Public::PieceController
  def pre_dispatch
    @piece = GpCalendar::Piece::DailyLink.find(Page.current_piece.id)
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

    @calendar.year_uri  = "#{@node.public_uri}:year/"
    @calendar.month_uri = "#{@node.public_uri}:year/:month/"
    @calendar.day_uri   = "#{@node.public_uri}:year/:month/#day:day"

    events = @content.public_events.scheduled_between(start_date, end_date)
    event_dates = events.flat_map { |event| to_dates(event, start_date, end_date) }.uniq

    docs = @content.event_docs.scheduled_between(start_date, end_date)
    doc_dates = docs.flat_map { |doc| to_dates(doc, start_date, end_date) }.uniq

    @calendar.day_link = (event_dates | doc_dates).sort

    if min_date && max_date
      @pagination = Util::Html::SimplePagination.new
      @pagination.prev_label = '前の月'
      @pagination.separator  = %Q(<span class="separator">|</span> <a href="#{@calendar.current_month_uri}">一覧</a> <span class="separator">|</span>)
      @pagination.next_label = '次の月'
      @pagination.prev_uri   = @calendar.prev_month_uri if @calendar.prev_month_date >= min_date
      @pagination.next_uri   = @calendar.next_month_uri if @calendar.next_month_date <= max_date
    end
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
