module GpArticle::GpArticleHelper
  def link_to_doc_options(doc)
    if doc.target.present?
      if doc.href.present?
        if doc.target == 'attached_file'
          if (file = doc.files.find_by(name: doc.href))
            ["#{doc.public_uri}file_contents/#{file.name}", target: '_blank']
          else
            nil
          end
        else
          [doc.href, target: doc.target]
        end
      else
        nil
      end
    else
      [doc.public_uri]
    end
  end

  def og_tags(item)
    return '' if item.nil?
    %w!type title description image!.map{ |key|
      unless item.respond_to?("og_#{key}") && (value = item.send("og_#{key}")).present?
        site = item.respond_to?(:site) ? item.site : item.content.site
        value = site.try("og_#{key}").to_s.gsub("\n", ' ')
        next value.present? ? tag(:meta, property: "og:#{key}", content: value) : nil
      end

      case key
      when 'image'
        if (file = item.image_files.detect{|f| f.name == value })
          tag :meta, property: 'og:image', content: "#{item.content.public_node.public_full_uri}#{item.name}/file_contents/#{url_encode file.name}"
        end
      else
        tag :meta, property: "og:#{key}", content: value.to_s.gsub("\n", ' ')
      end
    }.join.html_safe
  end

  def monthly_title(dates)
    dates.first.try(:strftime, '%Y年%-m月')
  end

  def weekly_title(dates)
    %Q(#{dates.first.try(:strftime, '%Y年%-m月%d日')}～#{dates.last.try(:strftime, '%Y年%-m月%d日')})
  end

  def period_pagination(prev_doc, next_doc, node, options = {})
    lang = options[:lang].presence || :ja
    previous_label = I18n.t("will_paginate.previous_label", {locale: lang})
    next_label     = I18n.t("will_paginate.next_label", {locale: lang})
    if request.mobile?
      previous_label = I18n.t("will_paginate.mobile_previous_label", {locale: lang})
      next_label     = I18n.t("will_paginate.mobile_next_label", {locale: lang})
    end


    links = content_tag(:div, class: 'pagination') do
      if prev_doc
        prev_date = prev_doc.published_at.beginning_of_month.strftime('.%Y%m') if node.content.monthly_pagination?
        prev_date = prev_doc.published_at.beginning_of_week.strftime('.%Y%m%d')  if node.content.weekly_pagination?
        prev_date = '' if @fisrt_day.strftime('.%Y%m%d') == prev_date
        prev_link = link_to previous_label, "#{node.public_uri}index#{prev_date}.html"
        concat content_tag(:span, prev_link.html_safe, class: 'previous_page', rel: 'previous')
      else
        concat content_tag(:span, previous_label, class: 'previous_page disabled', rel: 'previous')
      end
      concat content_tag(:span, '|', class: 'separator')
      if next_doc
        next_date = next_doc.published_at.beginning_of_month.strftime('.%Y%m') if node.content.monthly_pagination?
        next_date = next_doc.published_at.beginning_of_week.strftime('.%Y%m%d')  if node.content.weekly_pagination?
        next_link = link_to next_label, "#{node.public_uri}index#{next_date}.html"
        concat content_tag(:span, next_link.html_safe, class: 'next_page', rel: 'next')
      else
        concat content_tag(:span, next_label, class: 'next_page disabled', rel: 'next')
      end
    end
    links.html_safe
  end
end
