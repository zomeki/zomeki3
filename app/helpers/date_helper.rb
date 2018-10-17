module DateHelper
  def monthly_page_title(dates, date_style)
    dates.first.to_date.strftime(date_style)
  end

  def weekly_page_title(dates, date_style)
    %Q(#{dates.first.to_date.strftime(date_style)}～#{dates.last.to_date.strftime(date_style)})
  end

  def localize_wday(style, wday)
    style.gsub('%A', t('date.day_names')[wday]).gsub('%a', t('date.abbr_day_names')[wday])
  end

  def localize_ampm(style, time)
    style.gsub!('%H', '%I') if style =~ /%P/
    style.gsub('%P', I18n.t("time.#{time.strftime('%P')}"))
  end

  def qreki(tm, format = '旧%02d月%02d日')
    context = ExecJS.compile(Rails.root.join('vendor/qreki/qreki.js').read)
    kr = context.exec("var date = new Date(#{tm.year}, #{tm.month-1}, #{tm.day}); var kr = new kyureki(date.getJD()); return kr;")
    sprintf(format, kr['month'].to_i, kr['day'].to_i)
  end

  def display_whole_period(periods)
    all_days = periods.map { |period| [period.started_on, period.ended_on] }.flatten.compact
    return '' if all_days.blank?

    min = all_days.min
    max = all_days.max
    if min == max
      l(min)
    else
      "#{l(min)} ～ #{l(max)}".html_safe
    end
  end

  def display_short_period(period)
    if period.started_on == period.ended_on
      l(period.started_on)
    else
      html = l(period.started_on)
      html << ' ～ '
      html << l(period.ended_on)
      html.html_safe
    end
  end
end
