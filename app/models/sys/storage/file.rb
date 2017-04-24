class Sys::Storage::File < Sys::Storage::Entry
  define_attribute_methods :body

  after_save_files :save_storage_files
  before_remove_files :destroy_storage_files

  validates :name, presence: true
  with_options if: -> { name.present? } do
    validates :name, format: { with: /\A[0-9A-Za-z@\.\-\_]+\z/, message: 'は半角英数字で入力してください。' }
    validate :validate_mime_type
    validate :validate_file_size
  end

  def body
    return @body if defined? @body
    if ::Storage.exists?(path)
      @body = ::Storage.binread(path)
      @body = NKF.nkf('-w', @body) if text_file?
      @body
    end
  end

  def body=(val)
    body_will_change! unless val == @body
    @body = val
  end

  def mime_type
    ::Storage.mime_type(path)
  end

  def size
    ::Storage.size(path)
  end

  def kb_size
    ::Storage.kb_size(path)
  end

  def text_file?
    mime_type.blank? || mime_type =~ /(text|javascript|application\/json)/i
  end

  def save(options = {})
    super do
      if new_entry
        # new file
        ::Storage.binwrite(path, body) unless ::Storage.exists?(path)
      else
        # move
        if path_changed?
          ::Storage.mv(path_was, path) if ::Storage.exists?(path_was) && !::Storage.exists?(path)
        end
        # edit file
        if body_changed?
          ::Storage.binwrite(path, body) if ::Storage.exists?(path)
        end
      end
    end
  end

  def destroy
    super do
      ::Storage.rm_rf(path)
    end
  end

  private

  def set_defaults
    super
    self.entry_type = :file
  end

  def validate_mime_type
    return unless site

    types = site.setting_site_allowed_attachment_type.to_s.split(/ *, */)
    types = types.map { |t| ".#{t.gsub(/ /, '').downcase}" }.select(&:present?)

    if types.present? && !types.include?(::File.extname(name).downcase)
      errors.add(:base, "許可されていないファイルです。（#{types.join(', ')}）")
    end
  end

  def validate_file_size
    return unless site

    ext = ::File.extname(name).downcase
    max_size = site.get_upload_max_size(ext) || site.setting_site_file_upload_max_size

    if max_size && body && body.size > max_size.to_i * (1024**2)
      errors.add(:base, "容量制限を超えています。＜#{max_size}MB＞")
    end
  end

  def save_storage_files
    Sys::StorageFile.where(path: path_was).destroy_all if path_changed?
    Sys::StorageFile.find_or_initialize_by(path: path).update!(available: true)
  end

  def destroy_storage_files
    Sys::StorageFile.where(path: path).destroy_all
  end
end
