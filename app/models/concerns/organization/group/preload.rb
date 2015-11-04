module Concerns::Organization::Group::Preload
  extend ActiveSupport::Concern

  included do
    scope :preload_public_descendants_and_public_node_ancestors, -> {
      preload(public_descendants_and_public_node_ancestors_assocs)
    }
  end

  def preload_public_descendants
    assocs = self.class.public_descendants_assocs
    ActiveRecord::Associations::Preloader.new.preload(self, assocs)
  end

  module ClassMethods
    def public_descendants_assocs
      { parent: nil, public_children: {
          parent: nil, public_children: {
            parent: nil, public_children: nil
          }}}
    end

    def public_descendants_and_public_node_ancestors_assocs
      { content: {public_node: public_node_assocs}, parent: nil, public_children: {
          content: {public_node: public_node_assocs}, parent: nil, public_children: {
            content: {public_node: public_node_assocs}, parent: nil, public_children: nil
          }}}
    end

    private

    def public_node_assocs
      {site: nil, parent: {parent: {parent: nil}}}
    end
  end
end
