module Sys::Model::Rel::File
  extend ActiveSupport::Concern

  attr_accessor :in_tmp_id
  attr_accessor :in_file_names

  included do
    has_many :files, class_name: 'Sys::File', dependent: :destroy, as: :file_attachable
    before_save :make_file_path_relative
    before_save :fix_file_name, if: -> { in_file_names.present? }
    before_save :publish_files
    before_save :close_files
    after_create :fix_tmp_files, if: -> { in_tmp_id.present? }
  end

  def public_files_path
    "#{::File.dirname(public_path)}/files"
  end

  def publish_files
    return true unless @save_mode == :publish
    return true if Zomeki.config.application['sys.clean_statics']
    return true if files.empty?

    public_dir = public_files_path
    FileUtils.mkdir_p(public_dir) unless FileTest.exist?(public_dir)

    files.each do |file|
      paths = {
        file.upload_path               => "#{public_dir}/#{file.name}",
        file.upload_path(type: :thumb) => "#{public_dir}/thumb/#{file.name}"
      }
      paths.each do |fr, to|
        next unless FileTest.exists?(fr)
        next if FileTest.exists?(to) && ( ::File.mtime(to) >= ::File.mtime(fr) )
        FileUtils.mkdir_p(::File.dirname(to)) unless FileTest.exists?(::File.dirname(to))
        FileUtils.cp(fr, to)
      end
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
end
