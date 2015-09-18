module Sys::Model::Tree
  extend ActiveSupport::Concern

  def parents_tree(options = {})
    climb_parents_tree(id, :class => self.class)
  end

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

  module ClassMethods
    def roots
      self.where(parent_id: [0, nil])
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
