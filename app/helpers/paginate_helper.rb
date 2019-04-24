module PaginateHelper
  def paginate(items, options = {})
    return '' unless items

    defaults = { params: params.merge(jpmobile: nil),
                 previous_label: I18n.t('will_paginate.previous_label'),
                 next_label: I18n.t('will_paginate.next_label'),
                 link_separator: '<span class="separator"> | </span' + "\n" + '>',
                 renderer: LinkRenderer }

    if request.mobile?
      defaults.merge!(page_links: false,
                      previous_label: I18n.t('will_paginate.mobile_previous_label'),
                      next_label: I18n.t('will_paginate.mobile_next_label'))
    end
    defaults[:previous_label] = options[:previous_label] if options[:previous_label].present?
    defaults[:next_label]     = options[:next_label] if options[:next_label].present?

    will_paginate(items, defaults)
  end

  class LinkRenderer < WillPaginate::ActionView::LinkRenderer
    def url(page)
      if Core.request_uri == Core.internal_uri
        super
      else
        uri = Page.uri.dup
        uri.gsub!(/\/(\?|$)/, "/index.html\\1")
        uri.gsub!(/\.p[0-9]+\.html/, ".html")
        uri.gsub!(/\.html/, ".p#{page}.html") if page.to_i > 1
        uri
      end
    end

    def previous_or_next_page(page, text, classname)
      if page && @template.request.mobile?
        # set accesskey
        accesskey = classname == 'previous_page' ? '*' : '#'
        link(text, page, class: classname, accesskey: accesskey)
      else
        super
      end
    end
  end
end
