module Concerns::GpCategory::Category::Preload
  extend ActiveSupport::Concern

  module ClassMethods
    def public_children_and_public_node_ancestors_assocs
      { category_type: category_type_assocs, parent: nil, public_children: {
          category_type: category_type_assocs, parent: nil
        }}
    end

    def descendants_assocs
      { category_type: nil, parent: nil, children: {
          category_type: nil, parent: nil, children: {
            category_type: nil, parent: nil, children: nil
          }}}
    end

    def public_descendants_assocs
      { category_type: nil, parent: nil, public_children: {
          category_type: nil, parent: nil, public_children: {
            category_type: nil, parent: nil, public_children: nil
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
