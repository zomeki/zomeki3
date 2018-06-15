require 'digest/md5'
module Cms::Model::Base::Page::Publisher
  extend ActiveSupport::Concern

  included do
    has_many :publishers, class_name: 'Sys::Publisher', dependent: :destroy, as: :publishable
    #after_save :close_page
  end

  def public_uri
  end

  def public_full_uri
    return unless uri = public_uri
    "#{site.full_uri.chomp('/')}#{uri}"
  end

  def public_path
    return unless uri = public_uri
    "#{site.public_path}#{uri}"
  end

  def public_smart_phone_path
    return unless uri = public_uri
    "#{site.public_smart_phone_path}#{uri}"
  end

  def preview_uri(terminal: nil, params: {})
    return nil if (path = public_uri).blank?
    flag = { mobile: 'm', smart_phone: 's' }[terminal]
    query = "?#{params.to_query}" if params.present?
    "/_preview/#{format('%04d', site.id)}#{flag}#{path}#{query}"
  end

  def publishable?
    editable? && state.in?(%w(approved prepared recognized))
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
