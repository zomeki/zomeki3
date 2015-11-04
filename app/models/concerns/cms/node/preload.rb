module Concerns::Cms::Node::Preload
  extend ActiveSupport::Concern

  module ClassMethods
    def public_descendants_in_route_assocs(depth = 3)
      return nil if depth < 0
      { site: nil, content: nil, parent: nil, 
        public_children_in_route: public_descendants_in_route_assocs(depth - 1) }
    end
  end
end
