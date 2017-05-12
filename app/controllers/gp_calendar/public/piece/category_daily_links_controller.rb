class GpCalendar::Public::Piece::CategoryDailyLinksController < GpCalendar::Public::Piece::BaseController
  def pre_dispatch
    @piece = GpCalendar::Piece::CategoryDailyLink.find_by(id: Page.current_piece.id)
    return render(:text => '') unless @piece

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

    @calendar.day_uri   = "#{@node.public_uri}?start_date=:year-:month-:day&end_date=:year-:month-:day"

    events = @piece.content.events.public_state
                   .scheduled_between(start_date, end_date)
                   .content_and_criteria(@piece.content, {categories: @piece.category_ids}).to_a
    docs = @piece.content.public_event_docs(start_date, end_date)
    events = merge_docs_into_events(docs, events)

    days = docs.inject([]) do |dates, doc|
             dates | (doc.event_started_on..doc.event_ended_on).to_a
           end

    (start_date..end_date).each do |date|
      if events.detect {|e| e.started_on <= date && date <= e.ended_on }
        days << date unless days.include?(date)
      end
    end

    @calendar.day_link = days.sort!
  end
end
