module Cms::Model::Rel::Link
  extend ActiveSupport::Concern

  included do
    has_many :links, class_name: 'Cms::Link', dependent: :destroy, as: :linkable
    after_save :save_links
  end

  def save_links
    lib = links_in_body
    links.each do |link|
      link.destroy unless lib.detect {|l| l[:body] == link.body && l[:url] == link.url }
    end
    lib.each do |link|
      links.create(body: link[:body], url: link[:url], content_id: content_id) unless links.where(body: link[:body], url: link[:url]).first
    end
  end

end
