class GpCalendar::Public::Node::EventsController < GpCalendar::Public::NodeController
  skip_after_action :render_public_layout, only: [:file_content]

  def index
    http_error(404) if params[:page]

    start_date, end_date = if @year_only
                             boy = @date.beginning_of_year
                             boy = @min_date if @min_date > boy
                             eoy = @date.end_of_year
                             eoy = @max_date if @max_date < eoy
                             [boy, eoy]
                           else
                             [@date.beginning_of_month, @date.end_of_month]
                           end

    events = @content.public_events.scheduled_between(start_date, end_date)
    events = events.categorized_into(@specified_category.public_descendants) if @specified_category
    events = events.preload(:categories)

    docs = @content.event_docs.event_scheduled_between(start_date, end_date)
    docs = docs.categorized_into(@specified_category.public_descendants, categorized_as: 'GpCalendar::Event') if @specified_category

    @events = merge_events_and_docs(@content, events, docs)
  end

  def file_content
    @event = @content.events.find_by!(name: params[:name])
    file = @event.files.find_by!(name: "#{params[:basename]}.#{params[:extname]}")
    send_file file.upload_path, filename: file.name
  end
end
