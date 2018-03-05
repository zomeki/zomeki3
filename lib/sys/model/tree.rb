module Sys::Model::Tree
  extend ActiveSupport::Concern

  def root?
    parent_id.in?([0, nil])
  end

  def ancestors(items = [])
    parent.ancestors(items) if parent
    items << self
  end

  def descendants(items = [], &block)
    items << self
    rel = children
    rel = yield(rel) || rel if block_given?
    rel.each {|c| c.descendants(items, &block) }
    items
  end

  class_methods do
    def roots
      where(parent_id: [0, nil])
    end

    def root
      roots.first
    end

    def to_tree(parent: :parent, children: :children)
      items = all.to_a
      item_map = items.index_by { |item| item[primary_key] }

      items.each do |item|
        item.association(parent).loaded!
        item.association(children).loaded!
      end

      items.each do |item|
        if (pnt = item_map[item[reflect_on_association(children).foreign_key]])
          assoc = pnt.association(children)
          assoc.target << item
          assoc = item.association(parent)
          assoc.target = pnt
        end
      end

      items.select(&:root?)
    end
  end
end
