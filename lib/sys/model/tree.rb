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
      self.where(parent_id: [0, nil])
    end

    def root
      roots.first
    end
  end
end
