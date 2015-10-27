module Concerns::GpCategory::Category::Preload
  extend ActiveSupport::Concern

  included do
    scope :preload_public_children_and_public_node_ancestors, -> {
      preload(public_children_and_public_node_ancestors_assocs)
    }
    scope :preload_descendants, -> {
      preload(descendants_assocs)
    }
    scope :preload_public_descendants, -> {
      preload(public_descendants_assocs)
    }
    scope :preload_public_descendants_and_public_node_ancestors, -> {
      preload(public_descendants_and_public_node_ancestors_assocs)
    }
  end

  def preload_public_children_and_public_node_ancestors
    assocs = self.class.public_children_and_public_node_ancestors_assocs
    ActiveRecord::Associations::Preloader.new.preload(self, assocs)
  end

  def preload_descendants
    assocs = self.class.descendants_assocs
    ActiveRecord::Associations::Preloader.new.preload(self, assocs)
  end

  def preload_public_descendants
    assocs = self.class.public_descendants_assocs
    ActiveRecord::Associations::Preloader.new.preload(self, assocs)
  end

  def preload_public_descendants_and_public_node_ancestors
    assocs = self.class.public_descendants_and_public_node_ancestors_assocs
    ActiveRecord::Associations::Preloader.new.preload(self, assocs)
  end

  def descendants_with_preload
    preload_descendants
    descendants
  end

  module ClassMethods
    def public_children_and_public_node_ancestors_assocs
      { category_type: category_type_assocs, parent: nil, public_children: {
          category_type: category_type_assocs, parent: nil
        }}
    end

    def descendants_assocs
      { parent: nil, children: {
          parent: nil, children: {
            parent: nil, children: nil
          }}}
    end

    def public_descendants_assocs
      { parent: nil, public_children: {
          parent: nil, public_children: {
            parent: nil, public_children: nil
          }}}
    end

    def public_descendants_and_public_node_ancestors_assocs
      { category_type: category_type_assocs, parent: nil, public_children: {
          category_type: category_type_assocs, parent: nil, public_children: {
            category_type: category_type_assocs, parent: nil, public_children: nil
          }}}
    end

    private

    def public_node_assocs
      {site: nil, parent: {parent: {parent: nil}}}
    end

    def category_type_assocs
      {content: {public_node: public_node_assocs}}
    end
  end
end
