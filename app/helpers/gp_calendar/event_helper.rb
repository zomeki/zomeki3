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
      category: -> { event_replace_category(event) },
      image_link: -> { event_replace_image_link(event, link_to_options) },
      image: -> { event_replace_image(event) },
      note: -> {event_replace_note(event)}
    }
    tags = []

    list_style = content_tag(:tr) do
      table_style.each do |t|
        if t[:data] =~ %r|hold_date|
          class_str = 'date'
          class_str += ' holiday' if event.holiday.present?
          if @date && event.started_on.month == @date.month
            concat content_tag(:td, t[:data].html_safe, class: class_str, id: 'day%02d' % event.started_on.day)
          else
            concat content_tag(:td, t[:data].html_safe, class: class_str)
          end
        elsif
          class_str = t[:data].delete("@")
          concat content_tag(:td, t[:data].html_safe, class: class_str)
        end
      end
    end

    list_style = list_style.gsub(/@event{{@(.+)@}}event@/m){|m| link_to($1.html_safe, link_to_options[0], class: 'event_link') }
    list_style = list_style.gsub(/@category_type_(.+?)@/){|m| event_replace_category_type(event, $1) }
    list_style = list_style.gsub(/@(\w+)@/) {|m| contents[$1.to_sym] ? contents[$1.to_sym].call : '' }
    list_style.html_safe
  end

private

  def event_replace_title(event)
    content_tag(:span, event.title)
  end

  def event_replace_title_link(event, link_to_options)

    event_title = if link_to_options
                    link_to *([event.title] + link_to_options)
                  else
                    h event.title
                  end
    content_tag(:span, event_title)
  end

  def event_replace_subtitle(event)
    if doc = event.doc
      content_tag(:span, doc.subtitle)
    else
      ''
    end
  end

  def event_replace_hold_date(event, date_style)
    render 'gp_calendar/public/shared/event_date', event: event, date_style: date_style, holiday_disp: true
  end

  def event_replace_summary(event)
    content_tag(:span, hbr(event.description))
  end

  def event_replace_unit(event)
    if doc = event.doc
      content_tag(:span, doc.creator.group.try(:name))
    else
      content_tag(:span, event.creator.group.try(:name))
    end
  end

  def event_replace_category(event)
    replace_cateogry(event, event.categories)
  end

  def event_replace_category_type(event, category_type_name)
    category_type = GpCategory::CategoryType
      .where(content_id: event.content.category_content_id, name: category_type_name).first
    if category_type
      category_ids = event.categories.map{|c| c.id }
      categories = GpCategory::Category.where(category_type_id: category_type, id: category_ids)
      replace_cateogry(event, categories, category_type)
    else
      nil
    end
  end

  def replace_cateogry(event, categories, category_type = nil)
    if categories.present?
      category_tag = "";
      categories.each do |category|
        category_tag += content_tag(:span, category.title, class: category.name)
      end
      category_tag
    else
      ''
    end
  end

  def event_replace_image_link(event, link_to_options)
    image_tag = event_image_tag(event)
    image_link = if image_tag.present?
         if link_to_options
          link_to *([image_tag] + link_to_options)
        else
          image_tag
        end
      else
        image_tag
      end
    if image_link.present?
      content_tag(:span, image_link)
    else
      ''
    end
  end

  def event_replace_image(event)
    image_tag = event_image_tag(event)
    if image_tag.present?
      content_tag(:span, image_tag)
    else
      ''
    end
  end

  def event_image_tag(event)
    ei = event_image(event)
    ei.blank? ? '' : ei
  end

  def event_image(event)
    if (doc = event.doc)
      doc_image_tag(doc)
    elsif (f = event.image_files.first)
      image_tag("#{f.parent.content.public_node.public_uri}#{f.parent.name}/file_contents/#{url_encode f.name}", alt: f.title, title: f.title)
    elsif event.content.default_image.present?
      image_tag(event.content.default_image)
    end
  end

  def event_replace_note(event)
    if doc = event.doc
      content_tag(:span, hbr(doc.event_note))
    else
      content_tag(:span, hbr(event.note))
    end
  end

end
