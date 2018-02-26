module Cms::Model::Rel::Node
  extend ActiveSupport::Concern

  included do
    belongs_to :node, class_name: 'Cms::Node'
    delegate :site, to: :node
    delegate :site_id, to: :node
    nested_scope :in_site, through: :node
  end
end
