module Cms::Model::Rel::PublishUrl
  extend ActiveSupport::Concern

  included do
    has_many :publish_urls, class_name: 'Cms::PublishUrl', dependent: :destroy, as: :publishable
    after_save :set_public_name
  end

  def set_public_name
    return unless respond_to?(:state_public?) ? state_public? : state == 'public'
    return unless (node = kind_of?(Cms::Node) ? self : content.try!(:public_node))
    rel = publish_urls.find_or_initialize_by(content_id: content_id, node_id: node.id)
    rel.name = "#{uri = public_uri.to_s}#{'index.html' if uri.end_with?('/')}"
    rel.save
  end

end
