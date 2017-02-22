class Cms::Link < ApplicationRecord
  include Sys::Model::Base

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
