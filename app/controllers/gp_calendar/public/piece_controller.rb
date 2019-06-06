class GpCalendar::Public::PieceController < Cms::Controller::Public::Piece
  include GpArticle::Controller::Public::Scoping

  private

  def validate_date
    set_year_and_month_from_path

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

  def set_year_and_month_from_path
    return if params[:path].blank?

    paths = params[:path].split('/')
    return if paths.size < 2
    return unless paths[0] =~ /^[0-9]{4}$/ && paths[1] =~ /^[0-9]{1,2}$/

    params[:year], params[:month] = paths[0], paths[1]
  end
end
