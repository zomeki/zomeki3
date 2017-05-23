class Sys::Storage::Entry
  include ActiveModel::Model
  include ActiveModel::Dirty
  include ActiveModel::Callbacks
  include Sys::Model::Auth::Storage

  define_model_callbacks :initialize, :validation, :save_files, :remove_files
  define_attribute_methods :base_dir, :name
  attr_reader :base_dir, :name
  attr_accessor :entry_type, :site_id
  attr_accessor :allow_overwrite, :new_entry

  after_initialize :set_defaults

  after_save_files FileTransferCallbacks.new([:path, :path_was])
  after_remove_files FileTransferCallbacks.new([:path, :path_was])

  with_options if: -> { path.present? } do
    validate :validate_base_dir
    validate :validate_existence
  end

  def initialize(attrs = {})
    run_callbacks :initialize do
      super
    end
    changes_applied
  end

  def attributes
    [:base_dir, :name, :entry_type, :site_id, :allow_overwrite, :new_entry].each_with_object({}) do |attr, hash|
      hash.merge!(attr => read_attribute(attr))
    end
  end

  def read_attribute(attr)
    public_send(attr)
  end

  def base_dir=(val)
    base_dir_will_change! unless val == @base_dir
    @base_dir = val
  end

  def name=(val)
    name_will_change! unless val == @name
    @name = val
  end

  def path
    Pathname.new(::File.join(base_dir, name)).cleanpath.to_s
  end

  def path_was
    Pathname.new(::File.join(base_dir_was || base_dir, name_was || name)).cleanpath.to_s
  end

  def path_changed?
    path != path_was && path_was.present?
  end

  def mtime
    ::Storage.mtime(path)
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

  def themes_root_path
    ::File.join(site_root_path, "public/_themes").to_s
  end

  def themes_root_path?
    path == themes_root_path
  end

  def path_from_themes_root
    return if path !~ /^#{themes_root_path}/
    path.sub(/^#{themes_root_path}/, '').sub(%r|^/|, '')
  end

  def public_themes_uri
    return if path !~ /^#{themes_root_path}/
    "/_themes/#{path_from_themes_root}"
  end

  def parent
    return if site_root_path?
    @parent ||= self.class.from_path(File.dirname(path))
  end

  def children
    items = []
    if directory_entry?
      ::Storage.entries(path).each do |entry_name|
        item = self.class.from_path(::File.join(path, entry_name))
        items << item if item
      end
      items.sort_by! { |item| [item.entry_type, item.name] }
    end
    items
  end

  def validate
    run_callbacks :validation do
      return false if invalid?
    end
    return true
  end

  def save(options = {})
    if options[:validate].nil? || options[:validate]
      return false unless validate
    end

    ApplicationRecord.transaction do
      run_callbacks :save_files do
        yield
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
    run_callbacks :remove_files do
      yield
    end
    return true
  rescue => e
    error_log e
    errors.add(:base, e)
    return false
  end

  private

  def set_defaults
    self.allow_overwrite = true if allow_overwrite.nil?
    self.new_entry = true if new_entry.nil?

    if path.present? && site_id.nil? && (match = path.match(%r|^#{Rails.root}/sites/(\d+)|))
      self.site_id = match[1].to_i
    end
  end

  def validate_base_dir
    if base_dir =~ %r{\/\.\./|\/\./}
      errors.add(:base, '相対パスは使用できません。')
    end
  end

  def validate_existence
    if new_entry || !allow_overwrite || path_changed?
      if ::Storage.exists?(path)
        errors.add(:base, 'ファイルまたはディレクトリが既に存在します。')
      end
    end
  end

  class << self
    def from_path(path, new_as: nil)
      if (exist = ::Storage.directory?(path)) || new_as == :directory
        model = directory_model_from_path(path)
        model.new(base_dir: ::File.dirname(path), name: ::File.basename(path), new_entry: !exist)
      elsif (exist = ::Storage.file?(path)) || new_as == :file
        model = file_model_from_path(path)
        model.new(base_dir: ::File.dirname(path), name: ::File.basename(path), new_entry: !exist)
      end
    end

    private

    def themes_path?(path)
      path =~ %r|^#{Rails.root}/sites/\d+/public/_themes|
    end

    def directory_model_from_path(path)
      if themes_path?(path)
        Cms::Stylesheets::Directory
      else
        Sys::Storage::Directory
      end
    end

    def file_model_from_path(path)
      if themes_path?(path)
        Cms::Stylesheets::File
      else
        Sys::Storage::File
      end
    end
  end
end
