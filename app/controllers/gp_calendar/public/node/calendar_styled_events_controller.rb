class GpCalendar::Public::Node::CalendarStyledEventsController < GpCalendar::Public::NodeController
  def index
    http_error(404) if params[:page]

    start_date = @date.beginning_of_month.beginning_of_week(:sunday)
    end_date = @date.end_of_month.end_of_week(:sunday)

    @weeks = (start_date..end_date).inject([]) do |weeks, day|
        weeks.push([]) if weeks.empty? || day.wday.zero?
        weeks.last.push(day)
        next weeks
      end

    events = @content.public_events.scheduled_between(start_date, end_date)
    events = events.categorized_into(@specified_category.public_descendants) if @specified_category
    events = events.preload(:categories)

    docs = @content.event_docs.event_scheduled_between(start_date, end_date)
    docs = docs.categorized_into(@specified_category.public_descendants, categorized_as: 'GpCalendar::Event') if @specified_category

    @events = merge_events_and_docs(@content, events, docs)

    @holidays = @content.public_holidays.scheduled_between(start_date, end_date)
  end
end
