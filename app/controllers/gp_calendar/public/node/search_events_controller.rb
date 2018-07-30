class GpCalendar::Public::Node::SearchEventsController < GpCalendar::Public::NodeController
  skip_after_action :render_public_layout, only: [:file_content]

  def index
    http_error(404) if params[:page]

    @start_date = Date.parse(params[:start_date]) rescue nil || Date.today
    @end_date   = Date.parse(params[:end_date]) rescue nil || nil
    if params[:all] && params[:start_date].blank? && params[:end_date].blank?
      @start_date = nil
      @end_date   = nil
    end
    @date =  @start_date.present? ? @start_date : Date.today

    categories = params[:categories].present? ? params[:categories].values.reject(&:blank?) : []

    events = @content.public_events.scheduled_between(@start_date, @end_date)
    events = events.categorized_into(categories, alls: true) if categories.present?
    events = events.preload(:categories)

    docs = @content.event_docs.event_scheduled_between(@start_date, @end_date)
    docs = docs.categorized_into(categories, alls: true, categorized_as: 'GpCalendar::Event') if categories.present?

    @events = merge_events_and_docs(@content, events, docs)
  end

  def file_content
    @event = @content.events.find_by!(name: params[:name])
    file = @event.files.find_by!(name: "#{params[:basename]}.#{params[:extname]}")
    send_file file.upload_path, filename: file.name
  end
end
