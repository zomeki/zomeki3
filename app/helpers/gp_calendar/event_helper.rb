module GpCalendar::EventHelper
  def event_replace(event, list_style)
    link_to_options = if event.href.present?
                        [event.href, target: event.target]
                      else
                        nil
                      end

    list_style.gsub(/@\w+@/, {
      '@title_link@' => event_replace_title_link(event, link_to_options),
      '@title@' => event_replace_title(event)
    }).html_safe
  end

  def event_table_replace(event, table_style, options={})
    @content = event.content
    date_style = options && options[:date_style] ? options[:date_style] : @content.date_style

    link_to_options = if event.href.present?
                        [event.href, target: event.target]
                      else
                        nil
                      end

    contents = {
      title_link: -> { event_replace_title_link(event, link_to_options) },
      title: -> { event_replace_title(event) },
      subtitle: -> { event_replace_subtitle(event) },
      hold_date: -> { event_replace_hold_date(event, date_style) },
      summary: -> { event_replace_summary(event) },
      unit: -> { event_replace_unit(event) },
      category_link: -> { event_replace_category_link(event) },
      category: -> { event_replace_category(event) },
      image_link: -> { event_replace_image_link(event, link_to_options) },
      image: -> { event_replace_image(event) },
      note: -> {event_replace_note(event)}
    }
    tags = []

    list_style = content_tag(:tr) do
      table_style.each do |t|
        id = ''
        class_str = ''
        if t[:data] =~ %r|hold_date|
          id = 'day%02d' % event.started_on.day if event.started_on.month == @date.month
          class_str = 'date'
          class_str += ' holiday' if event.holiday.present?
        elsif t[:data] =~ %r|title|
          class_str = event.kind
        end
        concat content_tag(:td, t[:data], class: class_str, id: id)
      end
    end

    if Page.mobile?
      contents[:title_link].call
    else
      list_style = list_style.gsub(/@event{{@(.+)@}}event@/m){|m| link_to($1.html_safe, link_to_options[0], class: 'event_link') }
      list_style = list_style.gsub(/@category_type_link_(.+)@/){|m| event_replace_category_type_link(event, $1) }
      list_style = list_style.gsub(/@category_type_(.+)@/){|m| event_replace_category_type(event, $1) }
      list_style = list_style.gsub(/@(\w+)@/) {|m| contents[$1.to_sym] ? contents[$1.to_sym].call : '' }
      list_style.html_safe
    end
  end

private

  def event_replace_title(event)
    content_tag(:p, event.title, class: 'title')
  end

  def event_replace_title_link(event, link_to_options)

    event_title = if link_to_options
                    link_to *(link_to_options.unshift event.title)
                  else
                    h event.title
                  end
    content_tag(:p, event_title, class: 'title_link')
  end

  def event_replace_subtitle(event)
    if doc = event.doc
      content_tag(:p, doc.subtitle, class: 'subtitle')
    else
      ''
    end
  end

  def event_replace_hold_date(event, date_style)
    render 'gp_calendar/public/shared/event_date', event: event, date_style: date_style, holiday_disp: true
  end

  def event_replace_summary(event)
    content_tag(:p, hbr(event.description), class: 'summary')
  end

  def event_replace_unit(event)
    if doc = event.doc
      content_tag(:p, doc.creator.group.try(:name), class: 'subtitle')
    else
      content_tag(:p, event.creator.group.try(:name), class: 'subtitle')
    end
  end

  def event_replace_category_link(event)
    if event.categories.present?
      category_tag = content_tag(:p, class: 'category') do
        event.categories.each do |category|
          category_ln = link_to(category.title, category.public_uri)
          concat content_tag(:span, category_ln, class: 'category.name.capitalize')
        end
      end
      category_tag
    else
      ''
    end
  end

  def event_replace_category(event)
    if event.categories.present?
      category_tag = content_tag(:p, class: 'category') do
        event.categories.each do |category|
          concat content_tag(:span, category.title, class: 'category.name.capitalize')
        end
      end
      category_tag
    else
      ''
    end
  end

  def event_replace_category_type(event, category_type_name)
    if category_type = GpCategory::CategoryType.where(name: category_type_name).first
      content_tag(:span, category_type.title, class: 'category.name.capitalize')
    else
      ''
    end
  end

  def event_replace_category_type_link(event, category_type_name)
    if category_type = GpCategory::CategoryType.where(name: category_type_name).first
      category_ln = link_to(category_type.title, category_type.public_uri)
      content_tag(:span, category_ln, class: 'category.name.capitalize')
    else
      ''
    end
  end


  def event_replace_image_link(event, link_to_options)
    image_tag = event_image_tag(event)
    image_link = if image_tag.present? && link_to_options
        link_to *([image_tag] + link_to_options)
      else
        image_tag
      end
    if image_link.present?
      content_tag(:span, image_link, class: 'image')
    else
      ''
    end
  end

  def event_replace_image(event)
    image_tag = event_image_tag(event)
    if image_tag.present?
      content_tag(:span, image_tag, class: 'image')
    else
      ''
    end
  end

  def event_image_tag(event)
    ei = event_images(event, count: 1)
    ei.blank? ? '' : ei
  end

  def event_replace_note(event)
    if doc = event.doc
      content_tag(:p, hbr(doc.event_note), class: 'subtitle')
    else
      ''
    end
  end

end
