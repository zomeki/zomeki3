module Sys::Model::Rel::File
  extend ActiveSupport::Concern

  attr_accessor :in_tmp_id
  attr_accessor :in_file_names

  included do
    has_many :files, class_name: 'Sys::File', dependent: :destroy, as: :file_attachable
    before_save :make_file_path_relative, if: -> { in_tmp_id.present? }
    before_save :fix_file_name, if: -> { in_file_names.present? }
    after_create :fix_tmp_files, if: -> { in_tmp_id.present? }
  end

  def image_files
    files.select(&:image_file?)
  end

  private

  def fix_tmp_files
    Sys::File.fix_tmp_files(in_tmp_id, self)
    return true
  end

  def make_file_path_relative
    self.class.columns_having_file_name.each do |column|
      attr = read_attribute(column)
      next if attr.blank?

      if attr.is_a?(String)
        self[column] = make_file_path_relative_for(attr)
      elsif attr.is_a?(Hash)
        attr.each do |key, value|
          self[column][key] = make_file_path_relative_for(value)
        end
      end
    end
  end

  def make_file_path_relative_for(text)
    text.gsub(%r{("|')/[^'"]+?/inline_files/\d+/(file_contents[^'"]+?)("|')}, "\\1\\2\\3")
  end

  def fix_file_name
    in_file_names.each do |id, name|
      file = files.find_by(id: id)
      next if file.nil? || file.name == name
      self.class.columns_having_file_name.each do |column|
        attr = read_attribute(column)
        next if attr.blank?

        if attr.is_a?(String)
          self[column] = fix_file_name_for(attr, name, file.name)
        elsif attr.is_a?(Hash)
          attr.each do |key, value|
            self[column][key] = fix_file_name_for(value, name, file.name)
          end
        end
      end
    end
  end

  def fix_file_name_for(text, from, to)
    text.gsub(%r{("|')file_contents/#{from}("|')}, "\\1file_contents/#{to}\\2")
  end

  class_methods do
    def columns_having_file_name
      columns.select { |c| c.type == :text }.map(&:name)
    end
  end

  module Publication
    def public_files_path
      return '' if (path = public_path).blank?
      ::File.join(path.end_with?('/') ? path : File.dirname(path), "file_contents")
    end

    def public_smart_phone_files_path
      return '' if (path = public_smart_phone_path).blank?
      ::File.join(path.end_with?('/') ? path : File.dirname(path), "file_contents")
    end

    def publish_files
      path = public_files_path
      publish_files_to(path) if path.present?
      return true
    end

    def publish_smart_phone_files
      path = public_smart_phone_files_path
      publish_files_to(path, dependent: :smart_phone) if path.present?
      return true
    end

    def close_files
      files.each { |file| file.publishers.destroy_all }
      paths = [public_files_path, public_smart_phone_files_path].select(&:present?)
      paths.each { |path| FileUtils.rm_r(path) if FileTest.exist?(path) }
      return true
    end

    private

    def publish_files_to(public_dir, options = {})
      return true if Zomeki.config.application['sys.clean_statics']

      files.each do |file|
        paths = [
          [
            file.upload_path,
            ::File.join(public_dir, file.name),
            options[:dependent]
          ],[
            file.upload_path(type: :thumb),
            ::File.join(public_dir, 'thumb', file.name),
            ['thumb', options[:dependent]].compact.join('_')
          ]
        ]
        paths.each do |src, dst, dep|
          next unless FileTest.exists?(src)
          pub = file.publishers.where(dependent: dep).first_or_initialize
          pub.publish_file_with_digest(src, dst)
        end
      end
    end
  end
  include Publication
end
