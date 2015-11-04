module Concerns::Organization::Group::Preload
  extend ActiveSupport::Concern

  module ClassMethods
    def public_descendants_assocs(depth = 3)
      return nil if depth < 0
      { parent: nil, public_children: public_descendants_assocs(depth - 1) }
    end

    def public_descendants_and_public_node_ancestors_assocs(depth = 3)
      return nil if depth < 0
      { content: { public_node: { site: nil, parent: parent_assocs } },
        parent: nil, public_children: public_descendants_and_public_node_ancestors_assocs(depth - 1) }
    end

    private

    def parent_assocs(depth = 3)
      return nil if depth < 0
      { parent: parent_assocs(depth - 1) }
    end
  end
end
