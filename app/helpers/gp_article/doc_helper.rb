module GpArticle::DocHelper
  def doc_replace(doc, doc_style, date_style = '%Y年%m月%d日', time_style = '%H時%M分')
    Formatter.new(doc).format(doc_style, date_style, time_style, mobile: request.mobile?)
  end

  def og_tags(item)
    return '' if item.nil?
    %w!type title description image!.map{ |key|
      unless item.respond_to?("og_#{key}") && (value = item.send("og_#{key}")).present?
        site = item.respond_to?(:site) ? item.site : item.content.site
        value = site.try("og_#{key}").to_s.gsub("\n", ' ')
        next value.present? ? tag(:meta, property: "og:#{key}", content: value) : nil
      end

      case key
      when 'image'
        if (file = item.image_files.detect{|f| f.name == value })
          tag :meta, property: 'og:image', content: "#{item.content.public_node.public_full_uri}#{item.name}/file_contents/#{url_encode file.name}"
        end
      else
        tag :meta, property: "og:#{key}", content: value.to_s.gsub("\n", ' ')
      end
    }.join.html_safe
  end

  class Formatter < ActionView::Base
    include ::ApplicationHelper
    include ::DateHelper

    def initialize(doc)
      @doc = doc
    end

    def format(doc_style, date_style = '', time_style = '', mobile: false)
      link_options = @doc.link_to_options(preview: Core.mode == 'preview' && @doc.state != 'public')

      contents = {
        title_link: -> { replace_title_link(link_options) },
        title: -> { replace_title },
        subtitle: -> { replace_subtitle },
        publish_date: -> { replace_publish_date(date_style) },
        update_date: -> { replace_update_date(date_style) },
        publish_time: -> { replace_publish_time(time_style) },
        update_time: -> { replace_update_time(time_style) },
        summary: -> { replace_summary },
        group: -> { replace_group },
        category_link: -> { replace_category_link },
        category: -> { replace_category },
        image_tag: -> { replace_image_tag },
        image_link: -> { replace_image_link(link_options) },
        image: -> { replace_image },
        body_beginning: -> { replace_body_beginning },
        body: -> { replace_body },
        user: -> { replace_user },
        doc_no: -> { replace_doc_no }
      }

      html = if mobile
              contents[:title_link].call
            else
              doc_style = doc_style.gsub(/@doc{{@(.+)@}}doc@/m) { |m| link_to($1.html_safe, link_options[0], class: 'doc_link') }
              doc_style = doc_style.gsub(/@body_(\d+)@/) { |m| content_tag(:span, truncate(strip_tags(@doc.body), length: $1.to_i).html_safe, class: 'body') }
              doc_style = doc_style.gsub(/@(\w+)@/) { |m| contents[$1.to_sym].try(:call).to_s }
              doc_style.html_safe
            end

      if Core.mode == 'preview' && !@doc.state_public?
        content_tag :div, html, class: 'preview_future_public'
      else
        html
      end
    end

    private

    def file_path_expanded_body
      @doc.body.gsub(/("|')file_contents\//){|m| %Q(#{$1}#{@doc.public_uri(without_filename: true)}file_contents/) }
    end

    def doc_image_tag
      if @doc.list_image.present? && (image_file = @doc.image_files.detect { |f| f.name == @doc.list_image })
        image_tag("#{@doc.public_uri(without_filename: true)}file_contents/#{url_encode image_file.name}", alt: image_file.alt)
      elsif @doc.template &&
        (attach_item = @doc.template.public_items.where(item_type: 'attachment_file').first) &&
        (image_file = @doc.image_files.detect { |f| f.name == @doc.template_values[attach_item.name] })
        image_tag("#{@doc.public_uri(without_filename: true)}file_contents/#{url_encode image_file.name}", alt: image_file.alt)
      else
        body =
          if @doc.template
            rich_text_names = @doc.template.public_items.where(item_type: 'rich_text').map(&:name)
            rich_text_names.map { |name| @doc.template_values[name] }.join('')
          else
            @doc.body
          end
        unless (img_tags = Nokogiri::HTML.parse(body).css('img[src^="file_contents/"]')).empty?
          filename = File.basename(img_tags.first.attributes['src'].value)
          alt = img_tags.first.attributes['alt'].value
          image_tag("#{@doc.public_uri(without_filename: true)}file_contents/#{url_encode filename}", alt: alt)
        else
          ''
        end
      end
    end

    def replace_title_link(link_options)
      link = link_options ? link_to(*([@doc.title] + link_options)) : h(@doc.title)
      if link.present?
        content_tag(:span, link, class: 'title_link')
      end
    end

    def replace_title
      if @doc.title.present?
        content_tag(:span, @doc.title, class: 'title')
      end
    end

    def replace_subtitle
      if @doc.subtitle.present?
        content_tag(:span, @doc.subtitle, class: 'subtitle')
      end
    end

    def replace_publish_date(date_style)
      if (dpa = @doc.display_published_at)
        ds = localize_wday(date_style, dpa.wday)
        content_tag(:span, dpa.strftime(ds), class: 'publish_date')
      end
    end

    def replace_update_date(date_style)
      if (dua = @doc.display_updated_at)
        ds = localize_wday(date_style, dua.wday)
        content_tag(:span, dua.strftime(ds), class: 'update_date')
      end
    end

    def replace_publish_time(time_style)
      if (dpa = @doc.display_published_at)
        content_tag(:span, dpa.strftime(time_style), class: 'publish_time')
      end
    end

    def replace_update_time(time_style)
      if (dua = @doc.display_updated_at)
        content_tag(:span, dua.strftime(time_style), class: 'update_time')
      end
    end

    def replace_summary
      if @doc.summary.present?
        content_tag(:span, @doc.summary, class: 'summary')
      end
    end

    def replace_group
      if @doc.creator && @doc.creator.group
        content_tag(:span, @doc.creator.group.name, class: 'group')
      end
    end

    def replace_category_link
      if @doc.categories.present?
        category_text = @doc.categories.map {|c|
          content_tag(:span, link_to(c.title, c.public_uri), class: "#{c.category_type.name}-#{c.ancestors.map(&:name).join('-')}")
        }.join.html_safe
        content_tag(:span, category_text, class: 'category')
      end
    end

    def replace_category
      if @doc.categories.present?
        category_text = @doc.categories.map {|c|
          content_tag(:span, c.title, class: "#{c.category_type.name}-#{c.ancestors.map(&:name).join('-')}")
        }.join.html_safe
        content_tag(:span, category_text, class: 'category')
      end
    end

    def replace_image_tag
      doc_image_tag
    end

    def replace_image_link(link_options)
      image_tag = doc_image_tag
      image_link = if image_tag.present? && link_options
                     link_to *([image_tag] + link_options)
                   else
                     image_tag
                   end
      if image_link.present?
        content_tag(:span, image_link, class: 'image')
      end
    end

    def replace_image
      image_tag = doc_image_tag
      if image_tag.present?
        content_tag(:span, image_tag, class: 'image')
      end
    end

    def replace_body_beginning
      if @doc.body.present?
        more = content_tag(:div, link_to(@doc.body_more_link_text, @doc.public_uri), class: 'continues') if @doc.body_more.present?
        content_tag(:span, "#{file_path_expanded_body}#{more}".html_safe, class: 'body')
      end
    end

    def replace_body
      if @doc.body.present? || @doc.body_more.present?
        content_tag(:span, "#{file_path_expanded_body}#{@doc.body_more}".html_safe, class: 'body')
      end
    end

    def replace_user
      if @doc.creator && @doc.creator.user
        content_tag(:span, @doc.creator.user.name, class: 'user')
      end
    end

    def replace_doc_no
      if @doc.serial_no
        content_tag(:span, @doc.serial_no, class: 'docNo')
      end
    end
  end
end
