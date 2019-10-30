module Map::MarkerHelper
  def marker_table_replace(marker, table_style, date_style = '')
    Formatter.new(marker).format_table(table_style, date_style, mobile: request.mobile?)
  end

  class Formatter < ActionView::Base
    include ::ApplicationHelper
    include ::DateHelper
    include GpArticle::DocHelper
    include GpArticle::DocImageHelper

    def initialize(marker)
      @marker = marker
    end

    def format_table(table_style, date_style, mobile: false)
      link_options = marker_link_options

      contents = {
        title_link: -> { replace_title_link(link_options) },
        title: -> { replace_title },
        subtitle: -> { replace_subtitle },
        summary: -> { replace_summary },
        category: -> { replace_category },
        image_link: -> { replace_image_link(link_options) },
        image: -> { replace_image },
        marker_link: -> { replace_marker_link }
      }

      list_style = content_tag(:tr) do
        table_style.each do |t|
          class_str = t[:data].scan(/@(\w+)@/).flatten.join(' ')
          concat content_tag(:td, t[:data].html_safe, class: class_str)
        end
      end.html_safe

      list_style = list_style.gsub(/@marker{{@(.+)@}}marker@/m) { |m| link_to($1.html_safe, link_options[0], class: 'marker_link') }
      list_style = list_style.gsub(/@category_type_(.+?)@/) { |m| replace_category_type($1) }
      list_style = list_style.gsub(/@(\w+)@/) { |m| contents[$1.to_sym].try(:call).to_s }
      list_style.html_safe
    end

    private

    def marker_link_options
      if @marker.doc.present?
        doc_link_options(@marker.doc)
      else
        nil
      end
    end

    def replace_title
      content_tag(:span, @marker.title)
    end

    def replace_title_link(link_options)
      marker_title = if link_options
                       link_to *([@marker.title] + link_options)
                     else
                       h @marker.title
                     end
      content_tag(:span, marker_title)
    end

    def replace_subtitle
      if doc = @marker.doc
        content_tag(:span, doc.subtitle.html_safe)
      end
    end

    def replace_summary
      if doc = @marker.doc
        content_tag(:span, doc.summary.html_safe)
      end
    end

    def replace_category
      replace_with_categories(@marker.categories.to_a)
    end

    def replace_category_type(category_type_name)
      return '' unless @marker.content.gp_category_content_category_type

      category_type = @marker.content.gp_category_content_category_type
                             .category_types.where(name: category_type_name).first
      if category_type
        category_ids = @marker.categories.to_a.map(&:id)
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

    def replace_image_link(link_options)
      image_tag = marker_image_tag
      image_link =
        if image_tag.present?
          if link_options
            link_to *([image_tag] + link_options)
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
      image_tag = marker_image_tag
      if image_tag.present?
        content_tag(:span, image_tag)
      end
    end

    def marker_image_tag
      image = marker_image
      image.blank? ? '' : image
    end

    def marker_image
      if (doc = @marker.doc)
        GpArticle::DocHelper::Formatter.new(doc).format("@image_tag@")
      elsif (file = @marker.files.first) && @marker.content.public_node
        image_tag("#{@marker.public_uri}file_contents/#{url_encode file.name}", alt: '')
      elsif @marker.content.default_image.present?
        image_tag(@marker.content.default_image, alt: '')
      end
    end

    def replace_marker_link
      link_to('表示', '#map_canvas', onclick: "map.move_to('#{@marker.latitude}_#{@marker.longitude}'); return false;")
    end
  end
end
