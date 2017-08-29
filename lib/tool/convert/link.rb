class Tool::Convert::Link
  attr_accessor :cdoc, :tag, :attr, :url, :after_url, 
                :filename, :title, :alt, :ext, :file_path, 
                :message

  def url_changed?
    @url != @after_url
  end
end
