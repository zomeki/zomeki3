class DatePaginationQuery < ApplicationQuery
  def initialize(relation, options = {})
    @relation = relation
    @style = (options[:style] || :monthly).to_sym
    @column = (options[:column] || :updated_at).to_sym
    @direction = (options[:direction] || :desc).to_sym
    @current_date = options[:current_date]
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
    case @style
    when :monthly
      date = @current_date.present? ? "#{@current_date}01".to_time : first_page_date
      [date.beginning_of_month, date.end_of_month]
    when :weekly
      date = @current_date.present? ? @current_date.to_time : first_page_date
      [date.beginning_of_week, date.end_of_week]
    end
  end

  def prev_page_date
    page_dates = current_page_dates
    date =
      case @direction
      when :asc
        @relation.where(@relation.arel_table[@column].lt(page_dates.first))
                 .maximum(@column)
      when :desc
        @relation.where(@relation.arel_table[@column].gt(page_dates.last))
                 .minimum(@column)
      end
    beginning_of_page_date(date)
  end

  def next_page_date
    page_dates = current_page_dates
    date =
      case @direction
      when :asc
        @relation.where(@relation.arel_table[@column].gt(page_dates.last))
                 .minimum(@column)
      when :desc
        @relation.where(@relation.arel_table[@column].lt(page_dates.first))
                 .maximum(@column)
      end
    beginning_of_page_date(date)
  end

  private

  def beginning_of_page_date(date)
    case @style
    when :monthly
      date.try!(:beginning_of_month)
    when :weekly
      date.try!(:beginning_of_week)
    end
  end
end
