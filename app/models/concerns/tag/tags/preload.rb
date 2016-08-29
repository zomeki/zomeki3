module Tag::Tags::Preload
  extend ActiveSupport::Concern

  module ClassMethods
    def public_node_ancestors_assocs
      { content: { public_node: { site: nil, parent: parent_assocs } } }
    end

    private

    def parent_assocs(depth = 3)
      return nil if depth < 0
      { parent: parent_assocs(depth - 1) }
    end
  end
end
