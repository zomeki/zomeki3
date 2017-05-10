class GpCategory::CategoryPreloader < PreloaderQuery
  DEPTH_LIMIT = 5

  class << self
    def public_children_and_public_node_ancestors
      { category_type: category_types, parent: nil, public_children: {
          category_type: category_types, parent: nil } }
    end

    def descendants(depth = 0)
      return nil if depth > DEPTH_LIMIT
      { category_type: nil, parent: nil, children: descendants(depth + 1) }
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

    private

    def parents(depth = 0)
      return nil if depth > DEPTH_LIMIT
      { site: nil, parent: parents(depth + 1) }
    end

    def category_types
      { content: { public_node: { site: nil, parent: parents } } }
    end
  end
end
