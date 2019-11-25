module GpTemplate::TemplateHelper
  def template_body(template, template_values, files)
    template.items.inject(template.body.to_s) do |body, item|
      body.gsub(/\[\[item\/#{item.name}\]\]/i) { template_item_value(item, template_values[item.name].to_s, files) }
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
          value = tag('img', src: "file_contents/#{file.name}", title: file.title, alt: file.alt_text) 
        else
          value = content_tag('a', file.united_name, href: "file_contents/#{file.name}", class: file.css_class)
        end
      end
    when 'attachment_file_list'
      value = ''
      files.each do |f|
        value += '<li>' + content_tag('a', f.united_name, href: "file_contents/#{f.name}", class: f.css_class) + '</li>'
      end
      value = "<ul>#{value}</ul>" unless value.blank?
    end
    value
  end
end
