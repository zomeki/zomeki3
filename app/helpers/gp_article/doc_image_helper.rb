module GpArticle::DocImageHelper
  def doc_main_image_file(doc)
    ImageFileDetector.new(doc).detect
  end

  class ImageFileDetector
    def initialize(doc)
      @doc = doc
    end

    def detect
      list_image_file || template_image_file || body_first_image_file
    end

    private

    def list_image_file
      return if @doc.list_image.blank?
      @doc.image_files.detect { |f| f.name == @doc.list_image }
    end

    def template_image_file
      return unless @doc.template
      attachment = @doc.template.public_items.where(item_type: 'attachment_file').first
      return unless attachment
      @doc.image_files.detect { |f| f.name == @doc.template_values[attachment.name] }
    end

    def body_first_image_file
      body = if @doc.template
               rt_names = @doc.template.public_items.where(item_type: 'rich_text').map(&:name)
               rt_names.map { |name| @doc.template_values[name] }.join('')
             else
               @doc.body
             end
  
      img = Nokogiri::HTML.parse(body).css('img[src^="file_contents/"]').first
      return unless img
  
      filename = File.basename(img.attributes['src'].value)
      @doc.image_files.detect { |f| f.name == filename }
    end
  end
end
