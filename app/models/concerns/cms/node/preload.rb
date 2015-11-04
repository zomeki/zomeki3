module Concerns::Cms::Node::Preload
  extend ActiveSupport::Concern

  module ClassMethods
    def public_descendants_in_route_assocs
      { site: nil, content: nil, parent: nil, public_children_in_route: {
          site: nil, content: nil, parent: nil, public_children_in_route: {
            site: nil, content: nil, parent: nil, public_children_in_route: nil
          }}}
    end
  end
end
