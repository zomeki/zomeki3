module GpCalendar::EventHelper
  def event_replace(event, list_style)
    link_to_options = if event.href.present?
                        [event.href, target: event.target]
                      else
                        nil
                      end

    event_title = if link_to_options
                    link_to *(link_to_options.unshift event.title)
                  else
                    h event.title
                  end

    title_link = %Q!<p class="title_link">#{event_title}</p>!
    title = %Q!<p class="title">#{event.title}</p>!

    list_style.gsub(/@\w+@/, {
      '@title_link@' => title_link,
      '@title@' => title
    }).html_safe
  end
end
