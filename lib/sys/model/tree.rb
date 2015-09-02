module Sys::Model::Tree
  extend ActiveSupport::Concern

  def parents_tree(options = {})
    climb_parents_tree(id, :class => self.class)
  end

  def ancestors(items = [])
    parent.ancestors(items) if parent
    items << self
  end

  def descendants(items = [])
    items << self
    children.each {|c| c.descendants(items) }
    items
  end

  module ClassMethods
    def roots
      self.where([0, nil].map{|v| arel_table[:parent_id].eq(v)}.reduce(:or))
    end

    def root
      roots.first
    end
  end

private
  def climb_parents_tree(id, options = {})
    climbed = [id]
    tree    = []
    while current = options[:class].find_by(id: id)
      tree.unshift(current)
      id = current.parent_id
      break if climbed.index(id)
      climbed << id
    end
    return tree
  end
end
