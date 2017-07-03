class Cms::Link < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  belongs_to :linkable, polymorphic: true
  belongs_to :content, class_name: 'Cms::Content'

  define_site_scope :linkable

  def make_absolute_url(site)
    uri = Addressable::URI.parse(url)
    if uri.absolute?
      uri.to_s
    else
      if uri.path =~ /^\//
        "#{site.full_uri.sub(/\/$/, '')}#{uri.path}"
      else
        nil
      end
    end
  rescue => e
    error_log e
    error_log e.backtrace.join("\n")
    nil
  end
end
