module Sys::Model::Base::TextExtraction
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
    return unless respond_to?(:mime_type)
    return unless filepath = respond_to?(:upload_path) && upload_path
    return unless File.exists?(filepath)
    return unless File.extname(filepath).in?(EXTNAMES) && mime_type.in?(MIME_TYPES)

    result = Util::Tika.get_text(filepath)
    update_column :extracted_text, result
  end
end
