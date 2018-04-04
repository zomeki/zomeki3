module GpArticle::DocLinkHelper
  def doc_link_options(doc)
    uri = if Core.mode == 'preview' && !doc.state_public?
            "#{doc.public_uri(without_filename: true)}preview/#{doc.id}/#{doc.filename_for_uri}"
          else
            doc.public_uri
          end

    if doc.target.present? && doc.href.present?
      if doc.target == 'attached_file' && (file = doc.files.find_by(name: doc.href))
        [Addressable::URI.join(uri, "file_contents/#{file.name}").to_s, target: '_blank']
      else
        [doc.href, target: doc.target]
      end
    else
      [uri]
    end
  end

  def doc_main_image_file(doc)
    doc_list_image_file(doc) || doc_template_image_file(doc) || doc_body_first_image_file(doc)
  end

  private

  def doc_list_image_file(doc)
    return if doc.list_image.blank?
    doc.image_files.detect { |f| f.name == doc.list_image }
  end

  def doc_template_image_file(doc)
    return unless doc.template
    attachment = doc.template.public_items.where(item_type: 'attachment_file').first
    return unless attachment
    doc.image_files.detect { |f| f.name == doc.template_values[attachment.name] }
  end

  def doc_body_first_image_file(doc)
    body = if doc.template
             rt_names = doc.template.public_items.where(item_type: 'rich_text').map(&:name)
             rt_names.map { |name| doc.template_values[name] }.join('')
           else
             doc.body
           end

    img = Nokogiri::HTML.parse(body).css('img[src^="file_contents/"]').first
    return unless img

    filename = File.basename(img.attributes['src'].value)
    doc.image_files.detect { |f| f.name == filename }
  end
end
