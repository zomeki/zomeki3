class GpCalendar::Public::Node::TodaysEventsController < GpCalendar::Public::Node::BaseController
  def index
    http_error(404) if params[:page]

    criteria = {date: @today, kind: :event}
    @events = GpCalendar::Event.public_state.content_and_criteria(@content, criteria).order(:started_on).to_a

    docs = @content.public_event_docs(@today, @today)
                   .preload_assocs(:public_node_ancestors_assocs, :event_categories, :files)
    @events = merge_docs_into_events(docs, @events)

    filter_events_by_specified_category(@events)

    category_ids = @events.inject([]) {|i, e| i.concat(e.category_ids) }
    @event_categories = GpCategory::Category.where(id: category_ids)

    criteria = {date: @today, kind: :holiday}
    @holidays = GpCalendar::Holiday.public_state.content_and_criteria(@content, criteria)
  end
end
