module Concerns::GpArticle::Doc::Preload
  extend ActiveSupport::Concern

  included do
    scope :preload_public_node_ancestors, -> {
      preload(public_node_ancestors_assocs)
    }
    scope :preload_public_node_ancestors_and_main_associations, -> {
      preload_public_node_ancestors.preload_creator
    }
    scope :preload_organization_content_groups_and_public_node_ancestors, -> {
      preload(organization_content_groups_and_public_node_ancestors_assocs)
    }
    scope :preload_creator, -> {
      preload(creator: {group: nil, user: nil})
    }
  end

  module ClassMethods
    def public_node_ancestors_assocs
      {content: {public_node: public_node_assocs}}
    end

    def organization_content_groups_and_public_node_ancestors_assocs
      {content: {organization_content_group: {groups: organization_group_assocs}}}
    end

    private

    def public_node_assocs
      {site: nil, parent: {parent: {parent: nil}}}
    end

    def organization_group_assocs
      {content: {public_node: public_node_assocs}, parent: {parent: {parent: nil}}}
    end
  end
end
