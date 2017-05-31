class GpCalendar::Public::EventFormatService < FormatService
  def initialize(event, date)
    @event = event
    @date = date
  end

  def format(list_style, mobile: false)
    link_to_options = if @event.href.present?
                        [@event.href, target: @event.target]
                      else
                        nil
                      end

    list_style.gsub(/@\w+@/, {
      '@title_link@' => replace_title_link(link_to_options).to_s,
      '@title@' => replace_title.to_s,
      '@category@' => replace_category.to_s
    }).html_safe
  end

  def format_table(table_style, date_style = '', mobile: false)
    link_to_options = if @event.href.present?
                        [@event.href, target: @event.target]
                      else
                        nil
                      end

    contents = {
      title_link: -> { replace_title_link(link_to_options) },
      title: -> { replace_title },
      subtitle: -> { replace_subtitle },
      hold_date: -> { replace_hold_date(date_style) },
      summary: -> { replace_summary },
      unit: -> { replace_unit },
      category: -> { replace_category },
      image_link: -> { replace_image_link(link_to_options) },
      image: -> { replace_image },
      note: -> { replace_note }
    }

    list_style = content_tag(:tr) do
      table_style.each do |t|
        if t[:data] =~ %r|hold_date|
          class_str = 'date'
          class_str += ' holiday' if @event.holiday.present?
          if @date && @event.started_on.month == @date.month
            concat content_tag(:td, t[:data].html_safe, class: class_str, id: 'day%02d' % @event.started_on.day)
          else
            concat content_tag(:td, t[:data].html_safe, class: class_str)
          end
        else
          class_str = t[:data].delete("@")
          concat content_tag(:td, t[:data].html_safe, class: class_str)
        end
      end
    end

    list_style = list_style.gsub(/@event{{@(.+)@}}event@/m) { |m| link_to($1.html_safe, link_to_options[0], class: 'event_link') }
    list_style = list_style.gsub(/@category_type_(.+?)@/) { |m| replace_category_type($1) }
    list_style = list_style.gsub(/@(\w+)@/) { |m| contents[$1.to_sym].try(:call).to_s }
    list_style.html_safe
  end

  private

  def replace_title
    content_tag(:span, @event.title)
  end

  def replace_title_link(link_to_options)
    event_title = if link_to_options
                    link_to *([@event.title] + link_to_options)
                  else
                    h @event.title
                  end
    content_tag(:span, event_title)
  end

  def replace_subtitle
    if doc = @event.doc
      content_tag(:span, doc.subtitle)
    end
  end

  def replace_hold_date(date_style)
    s_style = localize_wday(date_style, @event.started_on.wday)
    e_style = localize_wday(date_style, @event.ended_on.wday)
    started_on = @event.started_on.strftime(s_style)
    ended_on = @event.ended_on.strftime(e_style)

    html = ''
    if @event.started_on == @event.ended_on
      html << content_tag(:span, started_on, class: 'startDate closeDate')
    else
      html << content_tag(:span, started_on, class: 'startDate')
      html << content_tag(:span, '～', class: 'from')
      html << content_tag(:span, ended_on, class: 'closeDate')
    end
    if @event.holiday.present?
      html << content_tag(:span, @event.holiday, class: 'title')
    end
    html.html_safe
  end

  def replace_summary
    content_tag(:span, hbr(@event.description))
  end

  def replace_unit
    if doc = @event.doc
      content_tag(:span, doc.creator.group.try(:name)) if doc.creator
    else
      content_tag(:span, @event.creator.group.try(:name)) if @event.creator
    end
  end

  def replace_category
    replace_with_categories(@event.categories.to_a)
  end

  def replace_category_type(category_type_name)
    category_type = GpCategory::CategoryType
      .where(content_id: @event.content.category_content_id, name: category_type_name).first

    if category_type
      category_ids = @event.categories.to_a.map(&:id)
      categories = GpCategory::Category.where(category_type_id: category_type, id: category_ids)
      replace_with_categories(categories)
    end
  end

  def replace_with_categories(categories)
    if categories.present?
      category_tag = "";
      categories.each do |category|
        category_tag += content_tag(:span, category.title, class: category.name)
      end
      category_tag
    end
  end

  def replace_image_link(link_to_options)
    image_tag = event_image_tag
    image_link =
      if image_tag.present?
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
    end
  end

  def replace_image
    image_tag = event_image_tag
    if image_tag.present?
      content_tag(:span, image_tag)
    end
  end

  def event_image_tag
    ei = event_image
    ei.blank? ? '' : ei
  end

  def event_image
    if (doc = @event.doc)
      GpArticle::Public::DocFormatService.new(doc).format("@image_tag@")
    elsif (f = @event.image_files.first)
      image_tag("#{f.parent.content.public_node.public_uri}#{f.parent.name}/file_contents/#{url_encode f.name}", alt: f.title, title: f.title)
    elsif @event.content.default_image.present?
      image_tag(@event.content.default_image)
    end
  end

  def replace_note
    if (doc = @event.doc)
      content_tag(:span, hbr(doc.event_note))
    else
      content_tag(:span, hbr(@event.note))
    end
  end
end
