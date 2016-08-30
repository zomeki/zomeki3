module Sys::Model::Rel::File
  extend ActiveSupport::Concern

  attr_accessor :in_tmp_id

  included do
    has_many :files, class_name: 'Sys::File', dependent: :destroy, as: :file_attachable
    before_save :publish_files
    before_save :close_files
    after_create { fix_tmp_files(in_tmp_id) if in_tmp_id.present? }
  end

  ## Remove the temporary flag.
  def fix_tmp_files(tmp_id)
    Sys::File.fix_tmp_files(tmp_id, self)
    return true
  end

  def public_files_path
    "#{::File.dirname(public_path)}/files"
  end

  def publish_files
    return true unless @save_mode == :publish
    return true if files.empty?

    dir = public_files_path
    FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)

    files.each do |file|
      next unless FileTest.exist?(file.upload_path)
      if FileTest.exist?(new_file = "#{dir}/#{file.name}")
        next if File::stat(new_file).mtime >= File::stat(file.upload_path).mtime
      end
      FileUtils.cp(file.upload_path, new_file) if FileTest.exist?(file.upload_path)
    end

    return true
  end

  def close_files
    return true unless @save_mode == :close

    dir = public_files_path
    FileUtils.rm_r(dir) if FileTest.exist?(dir)
    return true
  end

  def image_files
    files.select {|f| f.image_file? }
  end
end
