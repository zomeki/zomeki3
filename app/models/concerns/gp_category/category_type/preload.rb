module Concerns::GpCategory::CategoryType::Preload
  extend ActiveSupport::Concern

  included do
    scope :preload_public_node_ancestors, -> {
      preload(public_node_ancestors_assocs)
    }
    scope :preload_root_categories_and_descendants, -> {
      preload(root_categories_and_descendants_assocs)
    }
    scope :preload_public_root_categories_and_public_descendants_and_public_node_ancestors, -> {
      preload(public_root_categories_and_public_descendants_and_public_node_ancestors_assocs)
    }
  end

  def preload_root_categories_and_descendants
    assocs = self.class.root_categories_and_descendants_assocs
    ActiveRecord::Associations::Preloader.new.preload(self, assocs)
  end

  def preload_public_root_categories_and_public_descendants
    assocs = self.class.public_root_categories_and_public_descendants_assocs
    ActiveRecord::Associations::Preloader.new.preload(self, assocs)
  end

  def preload_public_root_categories_and_public_descendants_and_public_node_ancestors
    assocs = self.class.public_root_categories_and_public_descendants_and_public_node_ancestors_assocs
    ActiveRecord::Associations::Preloader.new.preload(self, assocs)
  end

  module ClassMethods
    def public_node_ancestors_assocs
      category_type_assocs
    end

    def root_categories_and_descendants_assocs
      {root_categories: {
        parent: nil, children: {
          parent: nil, children: {
            parent: nil, children: nil 
          }}}}
    end

    def public_root_categories_and_public_descendants_assocs
      {public_root_categories: {
        category_type: nil, parent: nil, public_children: {
          category_type: nil, parent: nil, public_children: {
            category_type: nil, parent: nil, public_children: nil 
          }}}}
    end

    def public_root_categories_and_public_descendants_and_public_node_ancestors_assocs
      {public_root_categories: {
        category_type: category_type_assocs, parent: nil, public_children: {
          category_type: category_type_assocs, parent: nil, public_children: {
            category_type: category_type_assocs, parent: nil, public_children: nil 
          }}}}
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
