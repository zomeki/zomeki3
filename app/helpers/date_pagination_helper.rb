module DatePaginationHelper
  def paginate_by_date(base_uri, first_date, prev_date, next_date, page_style: :monthly, prev_label:, next_label:, lang: :ja)
    prev_label = prev_label.presence || date_pagination_prev_label(lang)
    next_label = next_label.presence || date_pagination_next_label(lang)

    links = content_tag(:div, class: 'pagination') do
      if prev_date
        prev_pagination = date_style_pagination(prev_date, page_style)
        prev_pagination = '' if prev_pagination == date_style_pagination(first_date, page_style)
        prev_link = link_to prev_label, "#{base_uri}index#{prev_pagination}.html"
        concat content_tag(:span, prev_link, class: 'previous_page', rel: 'previous')
      else
        concat content_tag(:span, prev_label, class: 'previous_page disabled', rel: 'previous')
      end
      concat content_tag(:span, '|', class: 'separator')
      if next_date
        next_pagination = date_style_pagination(next_date, page_style)
        next_link = link_to next_label, "#{base_uri}index#{next_pagination}.html"
        concat content_tag(:span, next_link, class: 'next_page', rel: 'next')
      else
        concat content_tag(:span, next_label, class: 'next_page disabled', rel: 'next')
      end
    end
    links.html_safe
  end

  def date_style_pagination(date, page_style)
    case page_style.to_sym
    when :monthly
      date.beginning_of_month.strftime('.%Y%m')
    when :weekly
      date.beginning_of_week.strftime('.%Y%m%d')
    else
      raise 'invalid pagination style'
    end
  end

  def date_pagination_prev_label(lang)
    key =
      if request.mobile?
        "will_paginate.mobile_previous_label"
      else
        "will_paginate.previous_label"
      end
    I18n.t(key, locale: lang).html_safe
  end

  def date_pagination_next_label(lang)
    key =
      if request.mobile?
        "will_paginate.mobile_next_label"
      else
        "will_paginate.next_label"
      end
    I18n.t(key, locale: lang).html_safe
  end
end
