module DateHelper
  def monthly_page_title(dates, date_style)
    dates.first.to_date.strftime(date_style)
  end

  def weekly_page_title(dates, date_style)
    %Q(#{dates.first.to_date.strftime(date_style)}～#{dates.last.to_date.strftime(date_style)})
  end

  def qreki(tm, format = '旧%02d月%02d日')
    context = ExecJS.compile(Rails.root.join('vendor/qreki/qreki.js').read)
    kr = context.exec("var date = new Date(#{tm.year}, #{tm.month-1}, #{tm.day}); var kr = new kyureki(date.getJD()); return kr;")
    sprintf(format, kr['month'].to_i, kr['day'].to_i)
  end
end
