module Concerns::Tag::Tag::Preload
  extend ActiveSupport::Concern

  included do
    scope :preload_public_node_ancestors, -> {
      preload(public_node_ancestors_assocs)
    }
  end

  module ClassMethods
    def public_node_ancestors_assocs
      {content: {public_node: public_node_assocs}}
    end

    private

    def public_node_assocs
      {site: nil, parent: {parent: {parent: nil}}}
    end
  end
end
