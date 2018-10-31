class GpCalendar::Public::Node::SearchEventsController < GpCalendar::Public::NodeController
  skip_after_action :render_public_layout, only: [:file_content]

  def index
    http_error(404) if params[:page]

    params[:start_date] ||= Date.today.to_s
    start_date = Date.parse(params[:start_date]) rescue nil
    end_date   = Date.parse(params[:end_date]) rescue nil
    if params[:all] && params[:start_date].blank? && params[:end_date].blank?
      start_date = nil
      end_date   = nil
    end
    @date =  start_date.present? ? start_date : Date.today
    @range = [start_date, end_date]

    params[:year] = @date.year.to_s
    params[:month] = @date.month.to_s

    categories = params[:categories].present? ? params[:categories].values.reject(&:blank?) : []

    events = @content.public_events.scheduled_between(start_date, end_date)
    events = events.categorized_into(categories, alls: true) if categories.present?
    events = events.preload(:categories)

    docs = @content.event_docs.scheduled_between(start_date, end_date)
    docs = docs.categorized_into(categories, alls: true, categorized_as: 'GpCalendar::Event') if categories.present?

    @events = GpCalendar::EventMergeService.new(@content).merge(events, docs, @range)

    @holidays = @content.public_holidays.scheduled_between(start_date, end_date)
  end

  def file_content
    @event = @content.events.find_by!(name: params[:name])
    file = @event.files.find_by!(name: "#{params[:basename]}.#{params[:extname]}")
    send_file file.upload_path, filename: file.name
  end
end
