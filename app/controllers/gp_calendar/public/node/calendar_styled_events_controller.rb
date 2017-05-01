class GpCalendar::Public::Node::CalendarStyledEventsController < GpCalendar::Public::Node::BaseController
  def index
    http_error(404) if params[:page]

    criteria = {year_month: @date.strftime('%Y%m')}
    @events = GpCalendar::Event.public_state.content_and_criteria(@content, criteria).order(:started_on)
      .preload(:categories).to_a

    start_date = @date.beginning_of_month.beginning_of_week(:sunday)
    end_date = @date.end_of_month.end_of_week(:sunday)

    docs = @content.public_event_docs(start_date, end_date)
                   .preload_assocs(:public_node_ancestors_assocs, :event_categories, :files)
    @events = merge_docs_into_events(docs, @events)

    filter_events_by_specified_category(@events)

    @weeks = (start_date..end_date).inject([]) do |weeks, day|
        weeks.push([]) if weeks.empty? || day.wday.zero?
        weeks.last.push(day)
        next weeks
      end

    @holidays = GpCalendar::Holiday.public_state.content_and_criteria(@content, criteria)

    @values = Cms::ContentSetting.find_by(content_id: @content.id, name: "calendar_list_style")
  end
end
