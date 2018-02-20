module Sys::Model::Base::File::Db
  extend ActiveSupport::Concern

  def upload_path(options = {})
    nil
  end

  private

  def validate_file_name
  end

  def validate_file_type
  end

  def upload_internal_file
    update_columns(data: @file_content) if @file_content.present?
    update_columns(thumb_data: @thumbnail_image.to_blob) if @thumbnail_image
  end

  def remove_exif_from_image
  end

  def remove_internal_file
  end
end
