module GpTemplate::TemplateHelper
  def template_body(template, template_values, files)
    template.items.inject(template.body.to_s) do |body, item|
      body.gsub(/\[\[item\/#{item.name}\]\]/i, template_item_value(item, template_values[item.name].to_s, files))
    end
  end

  def template_item_value(item, value, files)
    return '' if item.state_closed?
    
    case item.item_type
    when 'text_area'
      value = br(value)
    when 'attachment_file'
      if file = files.detect {|f| f.name == value }
        if file.image_is == 1
          value = content_tag('image', '', src: "file_contents/#{file.name}", title: file.title) 
        else
          value = content_tag('a', file.united_name, href: "file_contents/#{file.name}", class: file.css_class)
        end
      end
    end
    value
  end

  def template_form(template, template_values)
    template.items.inject(template.body.to_s) do |body, item|
      body.gsub(/\[\[item\/#{item.name}\]\]/i, template_item_form(item, template_values[item.name].to_s))
    end
  end

  def template_item_form(item, value)
    return '' if item.state_closed?

    id = "item_template_values_#{item.name}"
    name = "item[template_values][#{item.name}]"
    html_attr = { id: id,
                  class: 'previewEdit',
                  style: item.style_attribute,
                  title: item.title,
                  placeholder: item.title,
                  data: { type: item.item_type, sync: true } }

    case item.item_type
    when 'text_field'
      text_field_tag(name, value, html_attr)
    when 'text_area'
      text_area_tag(name, value, html_attr)
    when 'select'
      options = item.item_options_for_select.map.with_index { |opt, i| [opt, opt, html_attr.merge(id: "#{id}_#{i}")] }
      select_tag(name, options_for_select(options, value), class: 'previewEdit', include_blank: true)
    when 'radio_button'
      item.item_options_for_select.map.with_index do |option, i|
        radio_button_tag(name, option, option == value, html_attr.merge(id: "#{id}_#{i}")) +
          content_tag('label', option, for: "#{id}_#{i}")
      end.join
    when 'attachment_file'
      text_field_tag(name, value, html_attr)
    when 'rich_text'
      content_tag('div', value, html_attr.merge(contenteditable: true))
    end
  end
end
