class Sys::Publisher < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  DIGEST_FILE_SIZE_LIMIT = 100 * 1024**2

  belongs_to :publishable, polymorphic: true

  before_validation :modify_path
  before_save :check_path
  before_destroy :remove_files

  scope :in_site, ->(site) { where(arel_table[:path].matches("./sites/#{format('%04d', site.id)}%")) }
  scope :with_ruby_dependent, -> {
    where(arel_table[:dependent].matches('%ruby')).where(arel_table[:path].matches('%.html.r'))
  }
  scope :with_talk_dependent, -> {
    where(arel_table[:dependent].matches('%talk')).where(arel_table[:path].matches('%.html.mp3'))
  }
  scope :with_smartphone_dependent, -> {
    where(arel_table[:dependent].matches('%smart_phone')).where(arel_table[:path].matches('%/public/_smartphone/%'))
  }

  def site_id
    path.scan(%r{^./sites/(\d+)}).dig(0, 0).try!(:to_i)
  end

  def site
    @site ||= Cms::Site.find_by(id: site_id)
  end

  def publish_with_digest(content, path)
    return false if Zomeki.config.application['cms.file_publisher'] == false
    return false if content.nil?
    return false if path.blank?

    hash = Digest::MD5.new.update(content).to_s
    return false if hash && content_hash && hash == content_hash && ::File.exist?(path)

    transaction do
      self.path = path
      self.content_hash = hash
      self.save if changed?

      if ::File.exist?(path) && ::File.new(path).read == content
        #FileUtils.touch([path])
      else
        Util::File.put(path, data: content, mkdir: true)
      end
    end
    return true
  end

  def publish_file_with_digest(src, dst)
    return false if Zomeki.config.application['cms.file_publisher'] == false
    return false unless FileTest.exists?(src)
    return false if dst.blank?

    if ::File.stat(src).size < DIGEST_FILE_SIZE_LIMIT
      hash = Digest::MD5.file(src).to_s
      return false if hash && content_hash && hash == content_hash && ::File.exist?(dst)
    end

    transaction do
      self.path = dst
      self.content_hash = hash if hash
      self.save if changed?

      if FileTest.exists?(dst) && ::File.mtime(dst) >= ::File.mtime(src)
        #FileUtils.touch([dst])
      else
        dir = ::File.dirname(dst)
        FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)
        FileUtils.cp(src, dst)
      end
    end
    return true
  end

  private

  def modify_path
    self.path = path.gsub(/^#{Rails.root.to_s}/, '.')
  end

  def check_path
    remove_files(path: path_was) if !path_was.blank? && path_changed?
    return true
  end

  def remove_files(options = {})
    up_path = options[:path] || path
    up_path = ::File.expand_path(path, Rails.root) if up_path.to_s.slice(0, 1) == '/'
    FileUtils.rm(up_path) if FileTest.exist?(up_path)
    #FileUtils.rm("#{up_path}.mp3") if FileTest.exist?("#{up_path}.mp3")
    FileUtils.rmdir(::File.dirname(up_path)) rescue nil
    return true
  end
end
