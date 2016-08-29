class Organization::Group < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Base::Page::Publisher

  include Cms::Model::Auth::Content

  include StateText
  include Organization::Groups::Preload

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  SITEMAP_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'display_published_at DESC, published_at DESC'],
                        ['公開日（昇順）', 'display_published_at ASC, published_at ASC']]

  default_scope { order("#{self.table_name}.sort_no IS NULL, #{self.table_name}.sort_no") }

  # Page
  belongs_to :concept, :class_name => 'Cms::Concept'
  belongs_to :layout, :class_name => 'Cms::Layout'
  belongs_to :more_layout, :class_name => 'Cms::Layout'

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Organization::Content::Group'
  validates :content_id, :presence => true

  belongs_to :sys_group, :foreign_key => :sys_group_code, :primary_key => :code, :class_name => 'Sys::Group'

  has_many :sys_group_children, :through => :sys_group, :source => :children
  has_one :sys_group_parent, :through => :sys_group, :source => :parent

  has_many :children, :through => :sys_group_children, :source => :organization_group
  has_one :parent, :through => :sys_group_parent, :source => :organization_group

  # conditional associations
  has_many :public_children, -> { public_state }, :through => :sys_group_children, :source => :organization_group

  after_initialize :set_defaults

  validates :sys_group_code, :presence => true, :uniqueness => true
  validates :name, :presence => true, :format => /\A[0-9A-Za-z\._-]*\z/i
  validate :name_uniqueness_in_siblings

  scope :public_state, -> { where(state: 'public') }
  scope :with_layout, ->(layout_id) {
    conds = [:layout_id, :more_layout_id].map { |c| arel_table[c].eq(layout_id) }
    where(conds.reduce(:or))
  }

  def sitemap_state_text
    SITEMAP_STATE_OPTIONS.detect{|o| o.last == self.sitemap_state }.try(:first).to_s
  end

  def docs_order_text
    DOCS_ORDER_OPTIONS.detect{|o| o.last == self.docs_order }.try(:first).to_s
  end

  def public?
    state == 'public'
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

  def path_from_root
    ancestors.map(&:name).join('/')
  end

  def descendants(groups=[])
    groups << self
    children.each{|c| c.descendants(groups) }
    return groups
  end

  def public_descendants(groups=[])
    return groups unless self.public?
    groups << self
    public_children.each{|c| c.public_descendants(groups) }
    return groups
  end

  def public_descendants_with_preload
    preload_assocs(:public_descendants_assocs)
    public_descendants
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

  def rebuild(content, options={})
    return false unless self.public?
    @save_mode = :publish
    publish_page(content, options)
  end

  def public_smart_phone_path
    return '' unless public_uri
    "#{content.site.public_path}/_smartphone#{public_uri}"
  end

  private

  def set_defaults
    self.state = STATE_OPTIONS.first.last if self.has_attribute?(:state) && self.state.nil?
    self.sitemap_state = SITEMAP_STATE_OPTIONS.first.last if self.has_attribute?(:sitemap_state) && self.sitemap_state.nil?
    self.docs_order = DOCS_ORDER_OPTIONS.first.last if self.has_attribute?(:docs_order) && self.docs_order.nil?
    self.sort_no = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end

  def name_uniqueness_in_siblings
    siblings = parent ? parent.children : content.root_groups
    errors.add(:name, :taken) unless siblings.where(name: name).where.not(id: id).empty?
  end
end
