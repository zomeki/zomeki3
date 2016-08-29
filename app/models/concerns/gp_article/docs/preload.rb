module GpArticle::Docs::Preload
  extend ActiveSupport::Concern

  module ClassMethods
    def creator_assocs
      { creator: { group: nil, user: nil } }
    end

    def public_index_assocs
      creator_assocs
    end

    def public_node_ancestors_assocs
      { content: { public_node: { site: nil, parent: parent_assocs } } }
    end

    def organization_groups_and_public_node_ancestors_assocs
      #{ content: { organization_content_group: { groups: organization_group_assocs } } }
      {}
    end

    private

    def parent_assocs(depth = 3)
      return nil if depth < 0
      { parent: parent_assocs(depth - 1) }
    end

    def organization_group_assocs
      { content: { public_node: { site: nil, parent: parent_assocs } }, parent: parent_assocs }
    end
  end
end
