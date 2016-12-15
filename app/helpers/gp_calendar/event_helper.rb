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
          id = ''
          id = 'day%02d' % event.started_on.day if @date && event.started_on.month == @date.month
          class_str = 'date'
          class_str += ' holiday' if event.holiday.present?
          concat content_tag(:td, t[:data].html_safe, class: class_str, id: id)
        elsif t[:data] =~ %r|title|
          class_str = event.kind
          concat content_tag(:td, t[:data].html_safe, id: id)
        else
          concat content_tag(:td, t[:data].html_safe)
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
    content_tag(:p, event.title, class: 'title')
  end

  def event_replace_title_link(event, link_to_options)

    event_title = if link_to_options
                    link_to *([event.title] + link_to_options)
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
      content_tag(:p, doc.creator.group.try(:name), class: 'unit')
    else
      content_tag(:p, event.creator.group.try(:name), class: 'unit')
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
      p_class = "category"
      p_class += " #{category_type.name}" if category_type
      category_tag = content_tag(:p, class: p_class) do
        categories.each do |category|
          concat content_tag(:span, category.title, class: category.name)
        end
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
    ei = event_image(event)
    ei.blank? ? '' : ei
  end

  def event_image(event)
    if doc = event.doc
      image_file = doc.list_image.present? ? doc.image_files.detect{|f| f.name == doc.list_image } : nil

      if image_file
        image_tag("#{doc.public_uri(without_filename: true)}file_contents/#{url_encode image_file.name}", alt: image_file.alt)
      else
        unless (img_tags = Nokogiri::HTML.parse(doc.body).css('img[src^="file_contents/"]')).empty?
          filename = File.basename(img_tags.first.attributes['src'].value)
          alt = img_tags.first.attributes['alt'].value
          image_tag("#{doc.public_uri(without_filename: true)}file_contents/#{url_encode filename}", alt: alt)
        else
          ''
        end
      end
    else
      return nil unless f = event.image_files.first
      image_tag("#{f.parent.content.public_node.public_uri}#{f.parent.name}/file_contents/#{url_encode f.name}", alt: f.title, title: f.title)
    end
  end

  def event_replace_note(event)
    if doc = event.doc
      content_tag(:p, hbr(doc.event_note), class: 'note')
    else
      content_tag(:p, hbr(event.note), class: 'note')
    end
  end

end
