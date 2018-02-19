class Organization::Group < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Site
  include Cms::Model::Base::Page
  include Cms::Model::Base::Sitemap
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  default_scope { order(:sort_no, :sys_group_code) }

  attribute :sort_no, :integer, default: 10

  enum_ish :state, [:public, :closed], default: :public, predicate: true
  enum_ish :docs_order, ['',
                         'display_published_at DESC, published_at DESC',
                         'display_published_at ASC, published_at ASC',
                         'display_updated_at DESC, updated_at DESC',
                         'display_updated_at ASC, updated_at ASC'], default: ''

  # Page
  belongs_to :concept, class_name: 'Cms::Concept'
  belongs_to :layout, class_name: 'Cms::Layout'
  belongs_to :more_layout, class_name: 'Cms::Layout'

  # Content
  belongs_to :content, class_name: 'Organization::Content::Group', required: true

  after_save     Organization::Publisher::GroupCallbacks.new, if: :changed?
  before_destroy Organization::Publisher::GroupCallbacks.new

  validates :sys_group_code, presence: true, uniqueness: { scope: :content_id }
  validates :name, presence: true, format: /\A[0-9A-Za-z\._-]*\z/i
  validate :name_uniqueness_in_siblings

  scope :public_state, -> { where(state: 'public') }
  scope :with_layout, ->(layout_ids) {
    conds = [:layout_id, :more_layout_id].map { |c| arel_table[c].in(layout_ids) }
    where(conds.reduce(:or))
  }

  def sys_group
    Sys::Group.in_site(content.site).where(code: sys_group_code).first
  end

  def parent
    return nil if sys_group.nil? || sys_group.parent.nil?
    content.groups.where(sys_group_code: sys_group.parent.code).first
  end

  def children
    content.groups.where(sys_group_code: sys_group.children.in_site(content.site).select(:code))
  end

  def public_children
    children.public_state
  end

  def public_uri
    return '' unless content.public_node
    "#{content.public_node.public_uri}#{path_from_root}/"
  end

  def public_full_uri
    return '' unless content.public_node
    "#{content.public_node.public_full_uri}#{path_from_root}/"
  end

  def ancestors(groups=[])
    parent.ancestors(groups) if parent
    groups << self
  end

  def public_ancestors
    ancestors.select { |g| g.state == 'public' }
  end

  def path_from_root
    ancestors.map(&:name).join('/')
  end

  def descendants(groups=[])
    groups << self
    children.each{|c| c.descendants(groups) }
    return groups
  end

  def public_descendants(groups=[])
    return groups unless self.state_public?
    groups << self
    public_children.each{|c| c.public_descendants(groups) }
    return groups
  end

  def bread_crumbs(public_node)
    crumbs = []

    if (node = content.try(:public_node))
      c = node.bread_crumbs.crumbs.first
      ancestors.each{|a| c << [a.sys_group.name, "#{node.public_uri}#{a.path_from_root}/"] }
      crumbs << c
    end

    if crumbs.empty?
      public_node.routes.each do |route|
        c = []
        route.each{|r| c << [r.title, r.public_uri] }
        crumbs << c
      end
    end

    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def public_smart_phone_path
    return '' unless public_uri
    "#{content.site.public_path}/_smartphone#{public_uri}"
  end

  def inherited_docs_order
    if docs_order.present?
      docs_order
    elsif parent
      parent.inherited_docs_order
    else
      content.docs_order_as_hash
    end
  end

  private

  def name_uniqueness_in_siblings
    siblings = parent ? parent.children : content.top_layer_groups
    errors.add(:name, :taken) unless siblings.where(name: name).where.not(id: id).empty?
  end
end
