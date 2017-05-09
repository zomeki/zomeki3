class Cms::NodePreloader < PreloaderQuery
  DEPTH_LIMIT = 5

  class << self
    def public_descendants_for_sitemap(depth = 0)
      return nil if depth > DEPTH_LIMIT
      { site: nil, content: nil, parent: nil,
        public_children_for_sitemap: public_descendants_for_sitemap(depth + 1) }
    end
  end
end
