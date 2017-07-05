module Cms::Model::Rel::Node
  extend ActiveSupport::Concern

  included do
    belongs_to :node, class_name: 'Cms::Node'
    delegate :site, to: :node
    delegate :site_id, to: :node
    scope :in_site, ->(site) { where(node_id: Cms::Node.where(site_id: site)) }
  end
end
