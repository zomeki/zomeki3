class Feed::Public::EntryFormatService < FormatService
  def initialize(entry)
    @entry = entry
  end

  def format(entry_style, date_style = '', time_style = '', mobile: false)
    contents = {
      title_link: -> { replace_title_link },
      title: -> { replace_title },
      publish_date: -> { replace_publish_date(date_style) },
      publish_time: -> { replace_publish_time(time_style) },
      summary: -> { replace_summary },
      category: -> { replace_category },
      image_link: -> { replace_image_link },
      image: -> { replace_image },
      feed_name: -> { replace_feed_name },
      new_mark: -> { replace_new_mark }
    }

    if mobile
      contents[:title_link].call
    else
      entry_style = entry_style.gsub(/@entry{{@(.+)@}}entry@/m) { |m| link_to($1.html_safe, @entry.public_uri, class: 'entry_link') }
      entry_style = entry_style.gsub(/@(\w+)@/) { |m| contents[$1.to_sym].try(:call).to_s }
      entry_style.html_safe
    end
  end

  private

  def entry_image_tag
    if @entry.image_uri.present?
      image_tag(@entry.image_uri, alt: @entry.title)
    end
  end

  def replace_title_link
    if @entry.title.present?
      link = link_to(@entry.title, @entry.public_uri, target: '_blank')
      content_tag(:span, link, class: 'title_link')
    end
  end
  
  def replace_title
    if @entry.title.present?
      content_tag(:span, @entry.title, class: 'title')
    end
  end

  def replace_publish_date(date_style)
    if (dpa = @entry.entry_updated)
      ds = localize_wday(date_style, dpa.wday)
      content_tag(:span, dpa.strftime(ds), class: 'publish_date')
    end
  end

  def replace_publish_time(time_style)
    if (dpa = @entry.entry_updated)
      content_tag(:span, dpa.strftime(time_style), class: 'publish_time')
    end
  end

  def replace_summary
    if @entry.summary.present?
      content_tag(:blockquote, @entry.summary.html_safe, class: 'summary')
    end
  end

  def replace_category
    unless @entry.categories.blank?
      category_text = @entry.categories.split(/\n/).map {|category| 
        content_tag(:span, category)
      }.join.html_safe
      content_tag(:span, category_text, class: 'category')
    end
  end

  def replace_image_link
    image_tag = entry_image_tag
    image_link = if image_tag.present?
                   link_to image_tag, @entry.public_uri, target: '_blank'
                 else
                   image_tag
                 end
    if image_link.present?
      content_tag(:span, image_link, class: 'image')
    end
  end

  def replace_image
    image_tag = entry_image_tag
    if image_tag.present?
      content_tag(:span, image_tag, class: 'image')
    end
  end
  
  def replace_new_mark
    if @entry.new_mark
      content_tag(:span, 'New', class: 'new')
    end
  end
  
  def replace_feed_name
    if @entry.feed
      @entry.feed.title
    end
  end
end
