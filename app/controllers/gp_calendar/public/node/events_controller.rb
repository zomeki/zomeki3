class GpCalendar::Public::Node::EventsController < GpCalendar::Public::Node::BaseController
  skip_after_action :render_public_layout, :only => [:file_content]

  def index
    http_error(404) if params[:page]

    year_month = @year_only ? @date.strftime('%Y') : @date.strftime('%Y%m')

    criteria = {year_month: year_month}
    @events = GpCalendar::Event.public_state.content_and_criteria(@content, criteria).order(:started_on)
      .preload(:categories).to_a

    start_date, end_date = if @year_only
                             boy = @date.beginning_of_year
                             boy = @min_date if @min_date > boy
                             eoy = @date.end_of_year
                             eoy = @max_date if @max_date < eoy
                             [boy, eoy]
                           else
                             [@date.beginning_of_month, @date.end_of_month]
                           end
    docs = @content.public_event_docs(start_date, end_date)
    @events = merge_docs_into_events(docs, @events)

    @holidays = GpCalendar::Holiday.public_state.content_and_criteria(@content, criteria).where(kind: :event)
    @holidays.each do |holiday|
      holiday.started_on = @date.year
      @events << holiday if holiday.started_on
    end
    @events.sort_by! { |e| e.started_on || Time.new(0) }

    filter_events_by_specified_category(@events)
  end

  def file_content
    @event = @content.events.find_by!(name: params[:name])
    file = @event.files.find_by!(name: "#{params[:basename]}.#{params[:extname]}")
    send_file file.upload_path, filename: file.name
  end
end
