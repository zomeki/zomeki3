module GpArticle::GpArticleHelper
  def doc_replace(doc, doc_style, date_style = '%Y年%m月%d日', time_style = '%H時%M分')
    GpArticle::Public::DocFormatService.new(doc).format(doc_style, date_style, time_style, mobile: Page.mobile?)
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
end
