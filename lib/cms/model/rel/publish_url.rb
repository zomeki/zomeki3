module Cms::Model::Rel::PublishUrl
  extend ActiveSupport::Concern

  included do
    has_many :publish_urls, class_name: 'Cms::PublishUrl', dependent: :destroy, as: :publishable
    after_save :save_publish_urls
  end

  def save_publish_urls
    return if state != 'public'
    return unless node = kind_of?(Cms::Node) ? self : content.public_node
    return unless uri = public_uri

    uri += 'index.html' if uri.end_with?('/')

    item = publish_urls.find_or_initialize_by(content_id: content_id, node_id: node.id)
    item.name = uri
    item.save
  end
end
