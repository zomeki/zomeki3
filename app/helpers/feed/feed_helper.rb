# encoding: utf-8
module Feed::FeedHelper
  
  def entry_replace(entry, entry_style, date_style, time_style='')
    contents = {
      title_link: -> { entry_replace_title_link(entry) },
      title: -> { entry_replace_title(entry) },
      subtitle: -> { entry_replace_subtitle(entry) },
      publish_date: -> { entry_replace_publish_date(entry, date_style) },
      publish_time: -> { entry_replace_publish_time(entry, time_style) },
      summary: -> { entry_replace_summary(entry) },
      category: -> { entry_replace_category(entry) },
      image_link: -> { entry_replace_image_link(entry) },
      image: -> { entry_replace_image(entry) },
      feed_name: -> { entry_replace_feed_name(entry) },
      new_mark: -> { entry_replace_new_mark(entry) }
    }

    if Page.mobile?
      contents[:title_link].call
    else
      entry_style = entry_style.gsub(/@entry{{@(.+)@}}entry@/m){|m| link_to($1.html_safe, entry.public_uri, class: 'entry_link') }
      entry_style = entry_style.gsub(/@(\w+)@/) {|m| contents[$1.to_sym] ? contents[$1.to_sym].call : '' }
      entry_style.html_safe
    end
  end

private

  def entry_image_tag(entry)
    unless entry.image_uri.blank?
      image_tag(entry.image_uri, alt: entry.title)
    else
      ''
    end
  end

  def entry_replace_title_link(entry)
    if entry.title.present?
      link = link_to(entry.title, entry.public_uri, :target => '_blank')
      content_tag(:span, link, class: 'title_link')
    else
      ''
    end
  end
  
  def entry_replace_title(entry)
    if entry.title.present?
      content_tag(:span, entry.title, class: 'title')
    else
      ''
    end
  end

  def entry_replace_publish_date(entry, date_style)
    if (dpa = entry.entry_updated)
      ds = localize_wday(date_style, dpa.wday)
      content_tag(:span, dpa.strftime(ds), class: 'publish_date')
    else
      ''
    end
  end

  def entry_replace_publish_time(entry, time_style)
    if (dpa = entry.entry_updated)
      content_tag(:span, dpa.strftime(time_style), class: 'publish_time')
    else
      ''
    end
  end

  def entry_replace_summary(entry)
    if entry.summary.present?
      content_tag(:blockquote, entry.summary, class: 'summary')
    else
      ''
    end
  end

  def entry_replace_category(entry)
    unless entry.categories.blank?
      category_text = entry.categories.split(/\n/).map {|category| 
        content_tag(:span, category)
      }.join.html_safe
      content_tag(:span, category_text, class: 'category')
    else
      ''
    end
  end

  def entry_replace_image_link(entry)
    image_tag = entry_image_tag(entry)
    image_link = if image_tag.present?
        link_to image_tag, :target => '_blank'
      else
        image_tag
      end
    if image_link.present?
      content_tag(:span, image_link, class: 'image')
    else
      ''
    end
  end

  def entry_replace_image(entry)
    image_tag = entry_image_tag(entry)
    if image_tag.present?
      content_tag(:span, image_tag, class: 'image')
    else
      ''
    end
  end
  
  def entry_replace_new_mark(entry)
    if entry.new_mark
      content_tag(:span, 'New', class: 'new')
    else
      ''
    end
  end
  
  def entry_replace_feed_name(entry)
    if entry.feed
      entry.feed.title
    end
  end

end
