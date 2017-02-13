module Sys::Model::TextExtraction
  extend ActiveSupport::Concern

  EXTNAMES = [
    '.dat',
    '.txt', '.pdf',
    '.doc', '.xls', '.ppt',
    '.docx', '.xlsx', '.pptx',
  ]

  MIME_TYPES = [
    'text/plain', 'application/pdf',
    'application/msword', 'application/vnd.ms-excel', 'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  ]

  included do
    after_save :extract_text
  end

  def extract_text
    return unless Zomeki.config.application['sys.file_text_extraction']
    return unless has_attribute?(:extracted_text)
    return unless respond_to?(:mime_type) && respond_to?(:path)
    return unless File.extname(path.to_s).in?(EXTNAMES) && File.exists?(path.to_s) && mime_type.in?(MIME_TYPES)

    jar = Rails.root.join('vendor/tika/tika-app.jar')
    result = `java -XX:TieredStopAtLevel=1 -Xverify:none -jar #{jar} --text #{path}`
    update_column :extracted_text, result
  rescue => e
    warn_log e.message
  end
end
