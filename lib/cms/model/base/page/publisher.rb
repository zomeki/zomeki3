require 'digest/md5'
module Cms::Model::Base::Page::Publisher
  def self.included(mod)
    mod.has_many :publishers, class_name: 'Sys::Publisher', dependent: :destroy, as: :publishable
    mod.after_save :close_page
  end

  def public_status
    return published_at ? '公開中' : '非公開'
  end

  def public_path
    return '' unless public_uri
    Page.site.public_path + public_uri
  end

  def public_uri
    '/'#TODO
  end

  def preview_uri(options = {})
    return nil unless public_uri
    site   = options[:site] || Page.site
    mobile = options[:mobile] ? 'm' : options[:smart_phone] ? 's' : nil
    params = []
    options[:params].each {|k, v| params << "#{k}=#{v}" } if options[:params]
    params = params.size > 0 ? "?#{params.join('&')}" : ""

    path = "_preview/#{format('%04d', site.id)}#{mobile}#{public_uri}#{params}"
    "#{site.main_admin_uri}#{path}"
  end

  def publish_uri(options = {})
    site = options[:site] || Page.site
    "#{site.full_uri}_publish/#{format('%04d', site.id)}#{public_uri}"
  end

  def publishable?
    return false unless editable?
    if respond_to?(:state_approved?)
      return false unless state_approved?
    else
      return false unless recognized?
    end
    return true
  end

  def rebuildable?
    return false unless editable?
    return state == 'public'# && published_at
  end

  def closable?
    return false unless editable?
    return state == 'public'# && published_at
  end

  def mobile_page?
    false
  end

  def published?
    @published
  end

  def publish_page(content, options = {})
    @published = false
    return false if content.nil?

    content = content.gsub(%r!zdel_.+?/!i, '')

    path = (options[:path] || public_path).gsub(/\/\z/, '/index.html')
    hash = Digest::MD5.new.update(content).to_s

    pub = publishers.where(dependent: options[:dependent] ? options[:dependent].to_s : nil).first

    return true if mobile_page?
    return true if hash && pub && hash == pub.content_hash && ::File.exist?(path)

clean_statics = Zomeki.config.application['sys.clean_statics']
if clean_statics
    if File.exist?(path)
      File.delete(path)
      info_log "DELETED: #{path}"
    end
    @published = true
else
    if ::File.exist?(path) && ::File.new(path).read == content
      #FileUtils.touch([path])
    else
      Util::File.put(path, :data => content, :mkdir => true)
      @published = true
    end
end

    pub ||= Sys::Publisher.new
    pub.publishable  = self
    pub.dependent    = options[:dependent] ? options[:dependent].to_s : nil
    pub.path         = path
    pub.content_hash = hash
    pub.save if pub.changed?
    return true
  end

  def close_page(options = {})
    publishers.destroy_all
    return true
  end
end
