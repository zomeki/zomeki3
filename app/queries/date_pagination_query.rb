class DatePaginationQuery < ApplicationQuery
  def initialize(relation, options = {})
    @relation = relation
    @page_style = (options[:page_style] || :monthly).to_sym
    @column = (options[:column] || :updated_at).to_sym
    @direction = (options[:direction] || :desc).to_sym
    @current_date = options[:current_date]
  end

  def page_info
    {
      first_date:    first_page_date,
      last_date:     last_page_date,
      current_dates: current_page_dates,
      prev_date:     prev_page_date,
      next_date:     next_page_date
    }
  end

  def first_page_date
    date =
      case @direction
      when :asc
        @relation.minimum(@column)
      when :desc
        @relation.maximum(@column)
      end
    beginning_of_page_date(date || Time.now)
  end

  def last_page_date
    date =
      case @direction
      when :asc
        @relation.maximum(@column)
      when :desc
        @relation.minimum(@column)
      end
    beginning_of_page_date(date || Time.now)
  end

  def current_page_dates
    date = @current_date.presence || first_page_date
    case @page_style
    when :monthly
      [date.beginning_of_month, date.end_of_month]
    when :weekly
      [date.beginning_of_week, date.end_of_week]
    end
  end

  def prev_page_date
    dates = current_page_dates
    date =
      case @direction
      when :asc
        @relation.where(@relation.arel_table[@column].lt(dates.first))
                 .maximum(@column)
      when :desc
        @relation.where(@relation.arel_table[@column].gt(dates.last))
                 .minimum(@column)
      end
    beginning_of_page_date(date)
  end

  def next_page_date
    dates = current_page_dates
    date =
      case @direction
      when :asc
        @relation.where(@relation.arel_table[@column].gt(dates.last))
                 .minimum(@column)
      when :desc
        @relation.where(@relation.arel_table[@column].lt(dates.first))
                 .maximum(@column)
      end
    beginning_of_page_date(date)
  end

  def page_dates
    case @page_style
    when :monthly
      date_sql = "TO_CHAR(#{@column}, 'YYYY-MM-01')"
      dates = @relation.group(date_sql).order("#{date_sql} #{@direction}").pluck(date_sql)
      dates.map { |date| Time.parse(date) }
    when :weekly
      date_sql = "TO_CHAR(#{@column}, 'IYYY-IW')"
      dates = @relation.group(date_sql).order("#{date_sql} #{@direction}").pluck(date_sql)
      dates.map do |date|
        iy, iw = date.split('-')
        Date.commercial(iy.to_i, iw.to_i).to_datetime
      end
    end
  end

  private

  def beginning_of_page_date(date)
    case @page_style
    when :monthly
      date.try!(:beginning_of_month)
    when :weekly
      date.try!(:beginning_of_week)
    end
  end
end
