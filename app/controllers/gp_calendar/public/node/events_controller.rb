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
    merge_docs_into_events(event_docs(start_date, end_date), @events)

    @holidays = GpCalendar::Holiday.public_state.content_and_criteria(@content, criteria).where(kind: :event)
    @holidays.each do |holiday|
      holiday.started_on = @date.year
      @events << holiday if holiday.started_on
    end
    @events.sort! {|a, b| a.started_on <=> b.started_on}

    filter_events_by_specified_category(@events)
  end

  def file_content
    @event = @content.events.find_by!(name: params[:name])
    file = @event.files.find_by!(name: "#{params[:basename]}.#{params[:extname]}")
    send_file file.upload_path, filename: file.name
  end

#TODO: OBSOLETED
  def index_monthly
    sdate = Date.new(@year, @month, 1)
    return http_error(404) unless sdate.between?(@min_date, @max_date)
    edate = 1.month.since(sdate)

    @calendar = Util::Date::Calendar.new(@year, @month)
    @calendar.month_uri = "#{@node.public_uri}:year/:month/"

    @items = {}
    @calendar.days.each {|d| @items[d[:date]] = [] if d[:month] == @month }

    event_docs(sdate, edate).each do |event|
      @items[event.event_date.to_s] << event
    end

    @pagination = Util::Html::SimplePagination.new
    @pagination.prev_label = '前の月'
    @pagination.next_label = '次の月'
    @pagination.prev_uri = @calendar.prev_month_uri if @calendar.prev_month_date >= @min_date
    @pagination.next_uri = @calendar.next_month_uri if @calendar.next_month_date <= @max_date

    render :index_monthly_mobile if Page.mobile?
  end

#TODO: OBSOLETED
  def index_yearly
    return http_error(404) unless @year.between?(@min_date.year, @max_date.year)
    sdate = Date.new(@year, 1, 1)
    edate = 1.year.since(sdate)

    @days  = []
    @items = {}

    wdays = Util::Date::Calendar.wday_specs

    event_docs(sdate, edate).each do |event|
      unless @items.has_key?(event.event_date.to_s)
        date = event.event_date
        wday = wdays[date.wday]
        day  = {
            :date_object => date,
            :date        => date.to_s,
            :class       => "day #{wday[:class]}",
            :wday_label  => wday[:label],
            :holiday     => Util::Date::Holiday.holiday?(date.year, date.month, date.day) || nil
          }
        day[:class].concat(' holiday') if day[:holiday]
        @days << day
        @items[event.event_date.to_s] = []
      end
      @items[event.event_date.to_s] << event
    end

    @pagination = Util::Html::SimplePagination.new
    @pagination.prev_label = '前の年'
    @pagination.next_label = '次の年'
    @pagination.prev_uri = "#{@node.public_uri}#{@year - 1}/" if (@year - 1) >= @min_date.year
    @pagination.next_uri = "#{@node.public_uri}#{@year + 1}/" if (@year + 1) <= @max_date.year
  end
end
