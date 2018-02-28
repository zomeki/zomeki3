class Cms::Link < ApplicationRecord
  include Sys::Model::Base

  belongs_to :linkable, polymorphic: true
  belongs_to :content

  nested_scope :in_site, through: :linkable

  def make_absolute_url(site)
    uri = Addressable::URI.parse(url)
    if uri.absolute?
      uri.to_s
    elsif uri.path =~ /^\//
      Addressable::URI.join(site.full_uri, uri.path).to_s
    elsif linkable.respond_to?(:public_uri) && (public_uri = linkable.public_uri).present?
      Addressable::URI.join(site.full_uri, public_uri, url).to_s
    end
  rescue => e
    error_log e
    nil
  end
end
