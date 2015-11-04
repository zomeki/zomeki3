module Concerns::GpArticle::Doc::Preload
  extend ActiveSupport::Concern

  module ClassMethods
    def public_index_assocs
      {creator: {group: nil, user: nil}}
    end

    def public_node_ancestors_assocs
      {content: {public_node: public_node_assocs}}
    end

    def organization_groups_and_public_node_ancestors_assocs
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
