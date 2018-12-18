class Gnav::MenuItem < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page
  include Cms::Model::Base::Sitemap
  include Cms::Model::Rel::Content

  default_scope { order(:sort_no, :id) }

  enum_ish :state, [:public, :closed], default: :public

  # Content
  belongs_to :content, class_name: 'Gnav::Content::MenuItem', required: true

  # Page
  belongs_to :concept, class_name: 'Cms::Concept'
  belongs_to :layout, class_name: 'Cms::Layout'

  has_many :category_sets

  accepts_nested_attributes_for :category_sets, allow_destroy: true

  before_save :mark_destruction_for_blank_category_sets

  validates :name, presence: true, uniqueness: { scope: :content_id }
  validates :title, presence: true

  after_save     Cms::Publisher::ContentCallbacks.new(belonged: true), if: :saved_changes?
  before_destroy Cms::Publisher::ContentCallbacks.new(belonged: true), prepend: true

  def public_uri
    return unless node = content.node
    "#{node.public_uri}#{name}/"
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
      next result unless category_set.category.state_public?
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

  private

  def mark_destruction_for_blank_category_sets
    category_sets.each do |cs|
      cs.mark_for_destruction if cs.category_id.blank?
    end
  end
end
