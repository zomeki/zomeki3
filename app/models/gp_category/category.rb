class GpCategory::Category < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Tree
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask

  include StateText
  include GpCategory::Categories::PublishQueue
  include GpCategory::Categories::Preload

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]
  SITEMAP_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'display_published_at DESC, published_at DESC'], ['公開日（昇順）', 'display_published_at ASC, published_at ASC'],
                        ['更新日（降順）', 'display_updated_at DESC, updated_at DESC'], ['更新日（昇順）', 'display_updated_at ASC, updated_at ASC']]

  default_scope { order(category_type_id: :asc, parent_id: :asc, level_no: :asc, sort_no: :asc, name: :asc) }

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :layout,  :foreign_key => :layout_id,  :class_name => 'Cms::Layout'
  belongs_to :template

  belongs_to :category_type, :foreign_key => :category_type_id, :class_name => 'GpCategory::CategoryType'
  validates :category_type_id, presence: true

  belongs_to :parent, :foreign_key => :parent_id, :class_name => self.name, :counter_cache => :children_count
  has_many :children, :foreign_key => :parent_id, :class_name => self.name, :dependent => :destroy

  validates :name, presence: true, uniqueness: { scope: [:category_type_id, :parent_id] },
                   format: { with: /\A[0-9A-Za-z@\.\-_\+\s]+\z/ }
  validates :title, presence: true
  validates :state, presence: true

  has_many :categorizations, dependent: :destroy
  has_many :doc_categorizations, -> { where(categorized_as: 'GpArticle::Doc') }, class_name: 'GpCategory::Categorization'

  has_many :docs, through: :doc_categorizations, source: :categorizable, source_type: 'GpArticle::Doc'
  has_many :markers, through: :categorizations, source: :categorizable, source_type: 'Map::Marker'
  has_many :events, -> { order(:started_on, :ended_on) },
                    through: :categorizations, source: :categorizable, source_type: 'GpCalendar::Event'

  has_many :marker_icons, :class_name => 'Map::MarkerIcon', :as => :relatable, :dependent => :destroy
  has_many :category_sets, :class_name => 'Gnav::CategorySet', :dependent => :destroy

  belongs_to :group, :foreign_key => :group_code, :class_name => 'Sys::Group'

  # conditional associations
  has_many :public_children, -> { public_state },
    :foreign_key => :parent_id, :class_name => self.name

  after_initialize :set_defaults

  before_validation :set_attributes_from_parent

  scope :with_root, -> { where(parent_id: nil) }
  scope :public_state, -> { where(state: 'public') }

  after_update :move_published_files
  after_update :clean_published_files
  after_destroy :clean_published_files

  def content
    category_type.content
  end

  def descendants(categories=[])
    categories << self
    children.each {|c| c.descendants(categories) }
    return categories
  end

  def descendants_ids
    preload_assocs(:descendants_assocs)
    descendants.map {|c| c.id }
  end

  def descendants_with_preload
    preload_assocs(:descendants_assocs)
    descendants
  end

  def public_descendants(categories=[])
    return categories unless self.public?
    categories << self
    public_children.each {|c| c.public_descendants(categories) }
    return categories
  end

  def public_descendants_ids
    preload_assocs(:public_descendants_assocs)
    public_descendants.map {|c| c.id }
  end

  def public_descendants_with_preload
    preload_assocs(:public_descendants_assocs)
    public_descendants
  end

  def descendants_for_option(categories=[])
    categories << ["#{'　　' * (level_no - 1)}#{title}", id]
    children.includes(:children).each {|c| c.descendants_for_option(categories) } unless children.empty?
    return categories
  end

  def ancestors(categories=[])
    parent.ancestors(categories) if parent
    categories << self
  end

  def path_from_root_category
    ancestors.map{|a| a.name }.join('/')
  end

  def bread_crumbs(category_type_node)
    crumbs = []

    if content
      if (node = content.public_node)
        c = node.bread_crumbs.crumbs.first
        c << [category_type.title, "#{node.public_uri}#{category_type.name}/"]
        ancestors.each {|a| c << [a.title, "#{node.public_uri}#{category_type.name}/#{a.path_from_root_category}/"] }
        crumbs << c
      end
    end

    if crumbs.empty?
      category_type_node.routes.each do |r|
        c = []
        r.each {|i| c << [i.title, i.public_uri] }
        crumbs << c
      end
    end

    Cms::Lib::BreadCrumbs.new(crumbs)
  end

  def public_docs
    docs.order(inherited_docs_order).mobile(::Page.mobile?).public_state
  end

  def copy_from_group(group)
    group.children.each do |child_group|
      if (child = children.where(group_code: child_group.code).first)
        new_state = (child_group.state == 'disabled' ? 'closed' : 'public')
        child.update_attributes(state: new_state, name: child_group.name_en, title: child_group.name, sort_no: child_group.sort_no)
      else
        if (old_child = children.find_by(name: child_group.name_en))
          old_child.update_column(:name, "#{old_child.name}_#{old_child.id}")
        end
        child = children.create(group_code: child_group.code, name: child_group.name_en, title: child_group.name, sort_no: child_group.sort_no)
      end
      child.copy_from_group(child_group) unless child_group.children.empty?
    end
  end

  def sitemap_visible?
    self.sitemap_state == 'visible'
  end

  def public_path
    return '' if (path = category_type.public_path).blank?
    "#{path}#{path_from_root_category}/"
  end

  def public_smart_phone_path
    return '' if (path = category_type.public_smart_phone_path).blank?
    "#{path}#{path_from_root_category}/"
  end

  def public_uri
    return '' if (uri = category_type.public_uri).blank?
    "#{uri}#{path_from_root_category}/"
  end

  def public_full_uri
    return '' if (uri = category_type.public_full_uri).blank?
    "#{uri}#{path_from_root_category}/"
  end

  def inherited_docs_order
    return self.docs_order if self.docs_order.present?
    return parent.inherited_docs_order if parent
    category_type.docs_order if category_type.docs_order.present?
    content.docs_order
  end

  def unique_sort_key
    ancestors.inject('') {|k, a| k.concat('__%032d_%32s_%032d_%032d_%032d_%032d_%32s' % [a.category_type.sort_no.to_i, a.category_type.name.to_s,
                                                                                         a.category_type_id.to_i, a.parent_id.to_i, a.level_no.to_i, a.sort_no.to_i, a.name.to_s]) }
  end

  def inherited_template
    return self.template if self.template
    return parent.inherited_template if parent
    category_type.template
  end

  private

  def set_defaults
    self.state         = STATE_OPTIONS.first.last         if self.has_attribute?(:state) && self.state.nil?
    self.sitemap_state = SITEMAP_STATE_OPTIONS.first.last if self.has_attribute?(:sitemap_state) && self.sitemap_state.nil?
    self.docs_order    = DOCS_ORDER_OPTIONS.first.last    if self.has_attribute?(:docs_order) && self.docs_order.nil?
    self.sort_no = 10 if self.has_attribute?(:sort_no) && self.sort_no.nil?
  end

  def set_attributes_from_parent
    if parent
      self.category_type = parent.category_type
      self.level_no = parent.level_no + 1
    else
      self.level_no = 1
    end
  end

  def clean_published_files
    FileUtils.rm_r(public_path) if public_path.present? && ::File.exist?(public_path)
    FileUtils.rm_r(public_smart_phone_path) if public_smart_phone_path.present? && ::File.exist?(public_smart_phone_path)
  end

  def move_published_files
    return if changes[:name].blank?
    old_name, new_name = changes[:name]
    return if old_name.blank? || new_name.blank?
    rename_directory(new_path: public_path, old_name: old_name)
    rename_directory(new_path: public_smart_phone_path, old_name: old_name)
  end

  def rename_directory(new_path:, old_name:)
    return unless Regexp.new("\\A#{Rails.root}/[^/]+") =~ new_path.to_s

    new_path = Pathname.new(new_path.to_s) unless new_path.kind_of?(Pathname)
    return if new_path.exist?

    old_path = new_path.dirname.join(old_name)
    return unless old_path.directory?

    old_path.rename(new_path)
  end
end
