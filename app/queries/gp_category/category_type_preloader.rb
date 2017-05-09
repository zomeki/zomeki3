class GpCategory::CategoryTypePreloader < PreloaderQuery
  DEPTH_LIMIT = 5

  class << self
    def public_node_ancestors
      category_types
    end

    def root_categories_and_descendants
      { root_categories: descendants }
    end

    def public_root_categories_and_public_descendants
      { public_root_categories: public_descendants }
    end

    def public_root_categories_and_public_descendants_and_public_node_ancestors
      { public_root_categories: public_descendants_and_public_node_ancestors }
    end

    private

    def descendants(depth = 0)
      return nil if depth > DEPTH_LIMIT
      { parent: nil, children: descendants(depth + 1) }
    end

    def public_descendants(depth = 0)
      return nil if depth > DEPTH_LIMIT
      { category_type: nil, parent: nil, public_children: public_descendants(depth + 1) }
    end

    def public_descendants_and_public_node_ancestors(depth = 0)
      return nil if depth > DEPTH_LIMIT
      { category_type: category_types, parent: nil, 
        public_children: public_descendants_and_public_node_ancestors(depth + 1) }
    end

    def parents(depth = 0)
      return nil if depth > DEPTH_LIMIT
      { site: nil, parent: parents(depth + 1) }
    end

    def category_types
      { content: { public_node: { site: nil, parent: parents } } }
    end
  end
end
