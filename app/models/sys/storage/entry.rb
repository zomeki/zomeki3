class Sys::Storage::Entry
  include ActiveModel::Model
  include ActiveModel::Dirty
  include ActiveSupport::Callbacks

  define_callbacks :validation, :save, :destroy
  define_attribute_methods :base_dir, :name, :body
  attr_accessor :entry_type, :site_id
  attr_accessor :allow_overwrite, :new_entry

  with_options if: -> { file_entry? } do
    validates :name, presence: { message: 'ファイル名を入力してください。' }
  end
  with_options if: -> { file_entry? && name.present? } do
    validates :name, format: { with: /\A[0-9A-Za-z@\.\-\_]+\z/, message: 'ファイル名は半角英数字で入力してください。' }
    validate :validate_mime_type
    validate :validate_file_size
  end

  with_options if: -> { directory_entry? } do
    validates :name, presence: { message: 'ディレクトリ名を入力してください。' }
  end
  with_options if: -> { directory_entry? && name.present? } do
    validates :name, format: { with: /\A[0-9A-Za-z@\.\-\_]+\z/, message: 'ディレクトリ名は半角英数字で入力してください。' }
    validates :name, format: { with: /\A[^_]/, message: '先頭に「_」を含むディレクトリは作成できません。' }
  end

  with_options if: -> { path.present? } do
    validate :validate_base_dir
    validate :validate_existence
  end

  def initialize(attrs = {})
    self.allow_overwrite = true
    self.new_entry = true
    super

    if path.present? && site_id.blank? && (match = path.match(%r|^#{Rails.root}/sites/(\d+)|))
      self.site_id = match[1].to_i
    end

    changes_applied
  end

  def read_attribute(attr)
    public_send(attr)
  end

  def base_dir
    @base_dir
  end

  def base_dir=(val)
    base_dir_will_change! unless val == @base_dir
    @base_dir = val
  end

  def name
    @name
  end

  def name=(val)
    name_will_change! unless val == @name
    @name = val
  end

  def body
    return @body if defined? @body
    if ::Storage.file?(path)
      @body = ::Storage.binread(path)
      @body = NKF.nkf('-w', @body) if text_file?
    end
    @body
  end

  def body=(val)
    body_will_change! unless val == @body
    @body = val
  end

  def path
    Pathname.new(::File.join(base_dir, name)).cleanpath.to_s
  end

  def path_was
    Pathname.new(::File.join(base_dir_was || base_dir, name_was || name)).cleanpath.to_s
  end

  def mtime
    ::Storage.mtime(path)
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

  def exists?
    ::Storage.exists?(path)
  end

  def directory_entry?
    entry_type == :directory
  end

  def file_entry?
    entry_type == :file
  end

  def text_file?
    return false unless file_entry?
    mime_type.blank? || mime_type =~ /(text|javascript)/i
  end

  def site
    @site ||= Cms::Site.find_by(id: site_id)
  end

  def site_root_path
    Rails.root.join("sites/#{format('%04d', site_id)}").to_s
  end

  def site_root_path?
    path == site_root_path
  end

  def path_from_site_root
    path.sub(site_root_path, '').sub(%r|^/|, '')
  end

  def readable?
    return false unless site
    return false unless Core.user.has_auth?(:designer)
    public_path = ::File.join(site_root_path, "public")
    Core.user.root? || (Core.user.sites.include?(site) && path =~ %r|^#{public_path}|)
  end

  def creatable?
    readable?
  end

  def editable?
    readable?
  end

  def deletable?
    readable?
  end

  def parent
    return if site_root_path?
    @parent ||= self.class.from_path(File.dirname(path))
  end

  def children
    items = []
    if directory_entry?
      ::Storage.entries(path).each do |entry_name|
        entry_path = ::File.join(path, entry_name)
        items << self.class.from_path(entry_path)
      end
      items.sort_by! { |item| [item.entry_type, item.name] }
    end
    items
  end

  def descendants(items = [])
    items << self
    children.each { |child| child.descendants(items) }
    items
  end

  def save(options = {})
    if options[:validate].nil? || options[:validate]
      run_callbacks :validation do
        return false if invalid?
      end
    end

    ApplicationRecord.transaction do
      run_callbacks :save do
        if new_entry
          # new file / new directory
          case entry_type
          when :directory
            ::Storage.mkdir(path) unless ::Storage.exists?(path)
          when :file
            ::Storage.binwrite(path, body) unless ::Storage.exists?(path)
          end
        else
          # move
          if path_was != path
            ::Storage.mv(path_was, path) if ::Storage.exists?(path_was) && !::Storage.exists?(path)
          end
          # edit file
          if body_changed?
            ::Storage.binwrite(path, body) if ::Storage.exists?(path)
          end
        end
      end
    end

    changes_applied
    return true
  rescue => e
    error_log e
    errors.add(:base, e)
    return false
  end

  def destroy
    run_callbacks :destroy do
      ::Storage.rm_rf(path)
    end
    return true
  rescue => e
    error_log e
    errors.add(:base, e)
    return false
  end

  private

  def validate_base_dir
    if base_dir =~ %r{\/\.\./|\/\./}
      errors.add(:base, '相対パスは使用できません。')
    end
  end

  def validate_existence
    if new_entry || !allow_overwrite || path != path_was
      if ::Storage.exists?(path)
        errors.add(:base, 'ファイルまたはディレクトリが既に存在します。')
      end
    end
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

  class << self
    def from_path(path)
      item = self.new(base_dir: ::File.dirname(path), name: ::File.basename(path))
      if ::Storage.directory?(path)
        item.entry_type = :directory
        item.new_entry = false
      elsif ::Storage.file?(path)
        item.entry_type = :file
        item.new_entry = false
      else
        item.new_entry = true
      end
      item
    end
  end
end
