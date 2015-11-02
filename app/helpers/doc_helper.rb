# encoding: utf-8
module DocHelper
  def doc_replace(doc, doc_style, date_style, time_style='')

    link_to_options = link_to_doc_options(doc)

    contents = {
      title_link: -> { doc_replace_title_link(doc, link_to_options) },
      title: -> { doc_replace_title(doc) },
      subtitle: -> { doc_replace_subtitle(doc) },
      publish_date: -> { doc_replace_publish_date(doc, date_style) },
      update_date: -> { doc_replace_update_date(doc, date_style) },
      publish_time: -> { doc_replace_publish_time(doc, time_style) },
      update_time: -> { doc_replace_update_time(doc, time_style) },
      summary: -> { doc_replace_summary(doc) },
      group: -> { doc_replace_group(doc) },
      category_link: -> { doc_replace_category_link(doc) },
      category: -> { doc_replace_category(doc) },
      image_link: -> { doc_replace_image_link(doc, link_to_options) },
      image: -> { doc_replace_image(doc) },
      body_beginning: -> { doc_replace_body_beginning(doc) },
      body: -> { doc_replace_body(doc) },
      user: -> { doc_replace_user(doc) },
      comment_count: -> { doc_replace_comment_count(doc) }
    }

    if Page.mobile?
      contents[:title_link].call
    else
      doc_style = doc_style.gsub(/@doc{{@(.+)@}}doc@/m){|m| link_to($1.html_safe, doc.public_uri, class: 'doc_link') }
      doc_style = doc_style.gsub(/@body_(\d+)@/){|m| content_tag(:span, truncate(strip_tags(doc.body), length: $1.to_i).html_safe, class: 'body') }
      doc_style = doc_style.gsub(/@(\w+)@/) {|m| contents[$1.to_sym] ? contents[$1.to_sym].call : '' }
      doc_style.html_safe
    end
  end

private

  def file_path_expanded_body(doc)
    doc.body.gsub(/("|')file_contents\//){|m| %Q(#{$1}#{doc.public_uri(without_filename: true)}file_contents/) }
  end

  def doc_image_tag(doc)
    image_file = doc.image_files.detect{|f| f.name == doc.list_image } || doc.image_files.first if doc.list_image.present?

    if image_file
      image_tag("#{doc.public_uri(without_filename: true)}file_contents/#{url_encode image_file.name}")
    else
      unless (img_tags = Nokogiri::HTML.parse(doc.body).css('img[src^="file_contents/"]')).empty?
        filename = File.basename(img_tags.first.attributes['src'].value)
        image_tag("#{doc.public_uri(without_filename: true)}file_contents/#{url_encode filename}")
      else
        ''
      end
    end
  end

  def doc_replace_title_link(doc, link_to_options)
    link = link_to_options ? link_to(*([doc.title] + link_to_options)) : h(doc.title)
    if link.present?
      content_tag(:span, link, class: 'title_link')
    else
      ''
    end
  end
  
  def doc_replace_title(doc)
    if doc.title.present?
      content_tag(:span, doc.title, class: 'title')
    else
      ''
    end
  end

  def doc_replace_subtitle(doc)
    if doc.subtitle.present?
      content_tag(:span, doc.subtitle, class: 'subtitle')
    else
      ''
    end
  end

  def doc_replace_publish_date(doc, date_style)
    if (dpa = doc.display_published_at)
      ds = localize_wday(date_style, dpa.wday)
      content_tag(:span, dpa.strftime(ds), class: 'publish_date')
    else
      ''
    end
  end

  def doc_replace_update_date(doc, date_style)
    if (dua = doc.display_updated_at)
      ds = localize_wday(date_style, dua.wday)
      content_tag(:span, dua.strftime(ds), class: 'update_date')
    else
      ''
    end
  end

  def doc_replace_publish_time(doc, time_style)
    if (dpa = doc.display_published_at)
      content_tag(:span, dpa.strftime(time_style), class: 'publish_time')
    else
      ''
    end
  end

  def doc_replace_update_time(doc, time_style)
    if (dua = doc.display_updated_at)
      content_tag(:span, dua.strftime(time_style), class: 'update_time')
    else
      ''
    end
  end

  def doc_replace_summary(doc)
    if doc.summary.present?
      content_tag(:span, doc.summary, class: 'summary')
    else
      ''
    end
  end

  def doc_replace_group(doc)
    if doc.creator && doc.creator.group
      content_tag(:span, doc.creator.group.name, class: 'group')
    else
      ''
    end
  end

  def doc_replace_category_link(doc)
    if doc.categories.present?
      category_text = doc.categories.map {|c|
        content_tag(:span, link_to(c.title, c.public_uri), class: "#{c.category_type.name}-#{c.ancestors.map(&:name).join('-')}")
      }.join.html_safe
      content_tag(:span, category_text, class: 'category')
    else
      ''
    end
  end

  def doc_replace_category(doc)
    if doc.categories.present?
      category_text = doc.categories.map {|c| 
        content_tag(:span, c.title, class: "#{c.category_type.name}-#{c.ancestors.map(&:name).join('-')}")
      }.join.html_safe
      content_tag(:span, category_text, class: 'category')
    else
      ''
    end
  end

  def doc_replace_image_link(doc, link_to_options)
    image_tag = doc_image_tag(doc)
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

  def doc_replace_image(doc)
    image_tag = doc_image_tag(doc)
    if image_tag.present?
      content_tag(:span, image_tag, class: 'image')
    else
      ''
    end
  end

  def doc_replace_body_beginning(doc)
    if doc.body.present?
      more = content_tag(:div, link_to(doc.body_more_link_text, doc.public_uri), class: 'continues') if doc.body_more.present?
      content_tag(:span, "#{file_path_expanded_body(doc)}#{more}".html_safe, class: 'body')
    else
      ''
    end
  end

  def doc_replace_body(doc)
    if doc.body.present? || doc.body_more.present?
      content_tag(:span, "#{file_path_expanded_body(doc)}#{doc.body_more}".html_safe, class: 'body')
    else
      ''
    end
  end

  def doc_replace_user(doc)
    if doc.creator && doc.creator.user
      content_tag(:span, doc.creator.user.name, class: 'user')
    else
      ''
    end
  end

  def doc_replace_comment_count(doc)
    content_tag(:span, link_to(doc.comments.count, "#{doc.public_uri}#comments"), class: 'comment_count')
  end
end
