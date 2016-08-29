module GpCategory::Categories::Preload
  extend ActiveSupport::Concern

  module ClassMethods
    def public_children_and_public_node_ancestors_assocs
      { category_type: category_type_assocs, parent: nil, public_children: {
          category_type: category_type_assocs, parent: nil
        }}
    end

    def descendants_assocs(depth = 3)
      return nil if depth < 0
      { category_type: nil, parent: nil, children: descendants_assocs(depth - 1) }
    end

    def public_descendants_assocs(depth = 3)
      return nil if depth < 0
      { category_type: nil, parent: nil, public_children: public_descendants_assocs(depth - 1) }
    end

    def public_descendants_and_public_node_ancestors_assocs(depth = 3)
      return nil if depth < 0
      { category_type: category_type_assocs, parent: nil,
        public_children: public_descendants_and_public_node_ancestors_assocs(depth - 1) }
    end

    private

    def parent_assocs(depth = 3)
      return nil if depth < 0
      { site: nil, parent: parent_assocs(depth - 1) }
    end

    def category_type_assocs
      { content: { public_node: { site: nil, parent: parent_assocs } } }
    end
  end
end
