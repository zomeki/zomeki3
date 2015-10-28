module Concerns::Cms::Node::Preload
  extend ActiveSupport::Concern

  included do
    scope :preload_public_descendants_in_route, -> {
      preload(public_descendants_in_route_assocs)
    }
  end

  module ClassMethods
    def public_descendants_in_route_assocs
      { site: nil, content: nil, parent: nil, public_children_in_route: {
          site: nil, content: nil, parent: nil, public_children_in_route: {
            site: nil, content: nil, parent: nil, public_children_in_route: nil
          }}}
    end
  end
end
