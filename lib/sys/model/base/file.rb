module Sys::Model::Base::File
  extend ActiveSupport::Concern

  IMAGE_RESIZE_OPTIONS = [['120px', '120'], ['160px', '160'], ['240px', '240'], ['320px', '320'],
                          ['480px', '480'],['640px', '640'], ['800px', '800'], ['1280px', '1280'],
                          ['1600px', '1600'], ['1920px', '1920']]

  IMAGE_FORMAT_TO_MIME_TYPE = { 'GIF'  => 'image/gif',
                                'JPEG' => 'image/jpeg',
                                'PNG'  => 'image/png' }

  DEFAULT_THUMBNAIL_SIZE = { width: 120, height: 90 }

  attr_accessor :file, :allowed_types, :image_resize

  included do
    include Sys::Model::TextExtraction

    alias :path :upload_path

    validates :file, presence: true, unless: :skip_upload?
    validates :name, :title, presence: true
    validate :validate_file_name, if: -> { name.present? }
    validate :validate_file_type, if: -> { allowed_types.present? }
    validate :validate_upload_file, if: -> { file.present? }
    before_save :set_upload_file_info, if: -> { file.present? }
    after_save :upload_internal_file
    after_save :remove_exif_from_image
    after_destroy :remove_internal_file

    define_model_callbacks :save_files, :remove_files
    after_save_files Cms::FileTransferCallbacks.new(:upload_path, recursive: true)
    after_remove_files Cms::FileTransferCallbacks.new(:upload_path, recursive: true)
  end

  def skip_upload(skip=true)
    @skip_upload = skip
  end

  def skip_upload?
    @skip_upload
  end

  def has_thumbnail?
    !thumb_width.nil?
  end

  def thumbnail_size
    return false if @thumbnail_size == false
    @thumbnail_size || DEFAULT_THUMBNAIL_SIZE
  end

  def thumbnail_size=(size)
    width, height = if size.to_s.index('x')
                      size.to_s.split('x').map(&:to_i)
                    else
                      [size.to_i, size.to_i]
                    end

    @thumbnail_size = if width > 0 && height > 0 && width <= 640 && height <= 480
                        { width: width, height: height }
                      else
                        DEFAULT_THUMBNAIL_SIZE
                      end
  end

  def allowed_types=(val)
    @allowed_types = if val.is_a?(String)
                       val.split(',').map { |type| type.strip.downcase }.select(&:present?)
                     else
                       val
                     end
  end

  def image_resize=(val)
    @image_resize = val.to_i if val.present?
  end

  def upload_path(options = {})
    site_dir = site_id ? "sites/#{format('%04d', site_id)}" : "."
    md_dir  = self.class.to_s.underscore.pluralize
    id_dir  = format('%08d', id).gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    id_file = options[:type] ? options[:type].to_s : format('%07d', id)
    id_file += '.dat'
    Rails.root.join("#{site_dir}/upload/#{md_dir}/#{id_dir}/#{id_file}").to_s
  end

  def image_file?
    image_is == 1
  end

  def csv_file?
    mime_type.in?(%w!text/csv application/vnd.ms-excel!)
  end

  def escaped_name
    CGI::escape(name)
  end

  def united_name
    "#{title}[#{::File.extname(name.to_s).gsub(/\./, '').upcase}：#{eng_unit}]"
  end

  def alt
    title.presence || name
  end

  def duplicated?
    nil
  end

  def css_class
    ApplicationController.helpers.file_icon_class(name)
  end

  def image_size
    ApplicationController.helpers.human_image_size(image_width, image_height)
  end

  def eng_unit
    ApplicationController.helpers.number_to_human_size(size)
  end

  def crop(x, y, w, h)
    image = Magick::Image.from_blob(File.read(upload_path)).first
    return false unless image.format.in?(%w!GIF JPEG PNG!)

    image.crop!(Magick::NorthWestGravity, x, y, w, h)
    image.write(upload_path)
    update_columns(size: File.size(upload_path),
                   image_width: image.columns,
                   image_height: image.rows)

    if thumbnail_size
      thumb = Magick::Image.from_blob(File.read(upload_path)).first
      thumb = thumb.resize_to_fit(thumbnail_size[:width], thumbnail_size[:height])
      thumb.write(upload_path(type: :thumb))
      update_columns(thumb_size: thumb.to_blob.size,
                     thumb_width: thumbnail_size[:width],
                     thumb_height: thumbnail_size[:height])
    end

    true
  rescue => e
    warn_log e
    false
  end

  private

  def validate_file_name
    if name !~ /^[0-9a-zA-Z\-\_\.]+$/ && !Zomeki.config.application['upload.allow_japanese_filename']
      errors.add :name, 'は半角英数字を入力してください。'
    elsif name !~ /^[^\.]+?\.[^\.]+$/
      errors.add(:name, 'を正しく入力してください。＜ファイル名.拡張子＞')
    elsif duplicated?
      errors.add :name, 'は既に存在しています。'
      return false
    end
  end

  def validate_file_type
    if name.present?
      ext = ::File.extname(name).downcase.delete('.')
      unless ext.in?(allowed_types)
        errors.add :base, "許可されていないファイルです。（#{allowed_types.join(', ')}）"
        return
      end
    end

    if file.present? && file.original_filename.present?
      ext = ::File.extname(file.original_filename).downcase.delete('.')
      unless ext.in?(allowed_types)
        errors.add :base, "許可されていないファイルです。（#{allowed_types.join(', ')}）"
        return
      end
    end
  end

  def validate_upload_file
    ext = ::File.extname(name.to_s).downcase.delete('.')
    maxsize = site ? site.file_upload_max_size_for(ext) : 5

    if file.size > maxsize  * (1024**2)
      errors.add :file, "が容量制限を超えています。＜#{maxsize}MB＞"
      return true
    end
  end

  def set_upload_file_info
    self.mime_type    = file.content_type
    self.size         = file.size
    self.image_is     = 2
    self.image_width  = nil
    self.image_height = nil
    self.thumb_width  = nil
    self.thumb_height = nil
    self.thumb_size = nil

    if Util::File.mime_type(file.path) =~ %r{image/(gif|jpeg|png)}
      image = begin
                Magick::Image.read(file.path).first
              rescue => e
                warn_log("#{self.mime_type}: #{e.message}")
                nil
              end
      if image && image.format.in?(%w!GIF JPEG PNG!)
        image.auto_orient!
        image.resize_to_fit!(image_resize) if image_resize

        if image.changed?
          image.write(file.path)
          self.size = image.to_blob.size
        end

        self.mime_type = IMAGE_FORMAT_TO_MIME_TYPE[image.format]
        self.image_is = 1
        self.image_width = image.columns
        self.image_height = image.rows

        if thumbnail_size
          @thumbnail_image  = image.resize_to_fit(thumbnail_size[:width], thumbnail_size[:height])
          self.thumb_width  = thumbnail_size[:width]
          self.thumb_height = thumbnail_size[:height]
          self.thumb_size   = @thumbnail_image.to_blob.size
        end
      end
    end

    @file_content = file.read
  end

  ## filter/aftar_save
  def upload_internal_file
    run_callbacks :save_files do
      Util::File.put(upload_path, data: @file_content, mkdir: true) if @file_content.present?
      Util::File.put(upload_path(type: :thumb), data: @thumbnail_image.to_blob, mkdir: true) if @thumbnail_image
      true
    end
  end

  def remove_exif_from_image
    if image_file?
      { size: upload_path, thumb_size: upload_path(type: :thumb) }.each do |column, path|
        if ::File.exist?(path)
          Util::File.remove_exif(path)
          update_columns(column => ::File.size(path))
        end
      end
    end
  end

  ## filter/aftar_destroy
  def remove_internal_file
    run_callbacks :remove_files do
      FileUtils.remove_entry_secure(upload_path) if ::File.exist?(upload_path)
      FileUtils.remove_entry_secure(upload_path(type: :thumb)) if ::File.exist?(upload_path(type: :thumb))
      true
    end
  end
end
