module DateHelper
  def monthly_page_title(dates, date_style)
    dates.first.to_date.strftime(date_style)
  end

  def weekly_page_title(dates, date_style)
    %Q(#{dates.first.to_date.strftime(date_style)}～#{dates.last.to_date.strftime(date_style)})
  end
end
