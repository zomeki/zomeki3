class Gnav::MenuItem < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page
  include Cms::Model::Base::Sitemap

  include StateText

  default_scope { order(:sort_no) }

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Gnav::Content::MenuItem'
  validates :content_id, :presence => true

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :layout,  :foreign_key => :layout_id,  :class_name => 'Cms::Layout'

  has_many :category_sets

  validates :name, :presence => true, :uniqueness => {:scope => :content_id}
  validates :title, :presence => true

  after_save     Cms::Publisher::ContentRelatedCallbacks.new, if: :changed?
  before_destroy Cms::Publisher::ContentRelatedCallbacks.new

  def public_uri
    return '' unless node = content.public_node
    "#{node.public_uri}#{name}/"
  end

  def public_path
    return '' unless node = content.public_node
    "#{node.public_path}#{name}/"
  end

  def public_smart_phone_path
    return '' unless node = content.public_node
    "#{node.public_smart_phone_path}#{name}/"
  end

  def public_full_uri
    return '' unless node = content.public_node
    "#{node.public_full_uri}#{name}/"
  end

  def categories
    category_sets.inject([]) {|result, category_set|
      if category_set.layer == 'descendants'
        result | category_set.category.descendants_with_preload
      else
        result | [category_set.category]
      end
    }
  end

  def public_categories
    category_sets.inject([]) {|result, category_set|
      next result unless category_set.category.public?
      if category_set.layer == 'descendants'
        result | category_set.category.public_descendants_with_preload
      else
        result | [category_set.category]
      end
    }
  end

  def bread_crumbs(menu_item_node)
    crumbs = []

    if content
      if (node = content.public_node)
        crumb = node.bread_crumbs.crumbs.first
        crumb << [title, "#{node.public_uri}#{name}/"]
        crumbs << crumb
      end
    end

    if crumbs.empty?
      menu_item_node.routes.each do |r|
        crumb = []
        r.each {|i| crumb << [i.title, i.public_uri] }
        crumbs << crumb
      end
    end

    Cms::Lib::BreadCrumbs.new(crumbs)
  end
end
