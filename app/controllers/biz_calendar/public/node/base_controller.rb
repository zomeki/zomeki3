class BizCalendar::Public::Node::BaseController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = BizCalendar::Content::Place.find_by(id: @node.content.id)
    return http_error(404) unless @content

    @today = Date.today
    @min_date = 1.year.ago(@today.beginning_of_month)
    @max_date = 11.months.since(@today.beginning_of_month)

    return http_error(404) unless validate_date

    # These params are used in pieces
    params[:gp_calendar_event_date]     = @date
    params[:gp_calendar_event_min_date] = @min_date
    params[:gp_calendar_event_max_date] = @max_date
  end

  private

  def validate_date
    @year_only = params[:year].to_i.nonzero? && params[:month].to_i.zero?

    @month = params[:month].to_i
    @month = @today.month if @month.zero?
    return false unless @month.between?(1, 12)

    @year = params[:year].to_i
    @year = @today.year if @year.zero?
    return false unless @year.between?(1900, 2100)

    @date = Date.new(@year, @month, 1)
    if @year_only
      @date.year.between?(@min_date.year, @max_date.year)
    else
      @date.between?(@min_date, @max_date)
    end
  end
end
