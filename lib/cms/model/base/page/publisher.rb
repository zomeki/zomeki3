require 'digest/md5'
module Cms::Model::Base::Page::Publisher
  extend ActiveSupport::Concern

  included do
    has_many :publishers, class_name: 'Sys::Publisher', dependent: :destroy, as: :publishable
    #after_save :close_page
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
    editable? && state.in?(%w(approved recognized))
  end

  def closable?
    editable? && state == 'public'
  end

  def published?
    @published
  end

  def publish_page(content, options = {})
    @published = false
    return false if content.nil?

    path = (options[:path] || public_path).gsub(/\/\z/, '/index.html')
    pub = Sys::Publisher.where(publishable: self, dependent: options[:dependent].to_s).first_or_initialize
    @published = pub.publish_with_digest(content, path)

    return true
  end

  def close_page(options = {})
    publishers.destroy_all
    return true
  end
end
