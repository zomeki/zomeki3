module Concerns::GpCategory::CategoryType::Preload
  extend ActiveSupport::Concern

  module ClassMethods
    def public_node_ancestors_assocs
      category_type_assocs
    end

    def root_categories_and_descendants_assocs
      { root_categories: descendants_assocs }
    end

    def public_root_categories_and_public_descendants_assocs
      { public_root_categories: public_descendants_assocs }
    end

    def public_root_categories_and_public_descendants_and_public_node_ancestors_assocs
      { public_root_categories: public_descendants_and_public_node_ancestors_assocs }
    end

    private

    def descendants_assocs(depth = 3)
      return nil if depth < 0
      { parent: nil, children: descendants_assocs(depth - 1) }
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

    def parent_assocs(depth = 3)
      return nil if depth < 0
      { site: nil, parent: parent_assocs(depth - 1) }
    end

    def category_type_assocs
      { content: { public_node: { site: nil, parent: parent_assocs } } }
    end
  end
end
