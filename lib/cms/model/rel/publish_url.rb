module Cms::Model::Rel::PublishUrl
  extend ActiveSupport::Concern

  included do
    has_many :publish_urls, class_name: 'Cms::PublishUrl', dependent: :destroy, as: :publishable
    after_save :set_public_name
  end

private

  def set_public_name
    return unless state_public?
    rel = publish_urls.first || publish_urls.build({content_id: content_id, node_id: content.public_node.try(:id)})
    rel.name = "#{public_uri(without_filename: true)}#{filename_base}.html"
    rel.save
  end

end
