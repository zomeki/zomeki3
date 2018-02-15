class GpCategory::CategoryType < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Site
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Cms::Model::Base::Sitemap
  include Cms::Model::Rel::Content

  default_scope { order(sort_no: :asc, name: :asc) }

  attribute :sort_no, :integer, default: 10

  enum_ish :state, [:public, :closed], default: :public, predicate: true
  enum_ish :docs_order, ['',
                         'display_published_at DESC, published_at DESC',
                         'display_published_at ASC, published_at ASC',
                         'display_updated_at DESC, updated_at DESC',
                         'display_updated_at ASC, updated_at ASC'], default: 'display_published_at DESC, published_at DESC'

  # Content
  belongs_to :content, class_name: 'GpCategory::Content::CategoryType', required: true

  # Page
  belongs_to :concept, class_name: 'Cms::Concept'
  belongs_to :layout, class_name: 'Cms::Layout'
  belongs_to :template
  belongs_to :internal_category_type, class_name: self.name

  has_many :categories, foreign_key: :category_type_id, class_name: 'GpCategory::Category', dependent: :destroy
  has_many :marker_icons, class_name: 'Map::MarkerIcon', as: :relatable, dependent: :destroy

  # conditional associations
  has_many :root_categories, -> { with_root },
    :foreign_key => :category_type_id, :class_name => 'GpCategory::Category'
  has_many :public_categories, -> { public_state },
    :foreign_key => :category_type_id, :class_name => 'GpCategory::Category'
  has_many :public_root_categories, -> { public_state.with_root },
    :foreign_key => :category_type_id, :class_name => 'GpCategory::Category'

  validates :name, presence: true, uniqueness: { scope: :content_id },
                   format: { with: /\A[0-9A-Za-z@\.\-_\+\s]+\z/ }
  validates :title, presence: true
  validates :state, presence: true

  after_save     GpCategory::Publisher::CategoryTypeCallbacks.new, if: :changed?
  before_destroy GpCategory::Publisher::CategoryTypeCallbacks.new

  scope :public_state, -> { where(state: 'public') }

  after_destroy :clean_published_files

  def root_categories_for_option
    root_categories.map {|c| [c.title, c.id] }
  end

  def categories_for_option
    root_categories.map{|c| c.descendants_for_option }.flatten(1)
  end

  def find_category_by_path_from_root_category(path_from_root_category)
    category_names = path_from_root_category.split('/')
    category_names.inject(root_categories.find_by(name: category_names.shift)) {|result, item|
      result.children.find_by(name: item)
    }
  end

  def public_path
    return '' unless node = content.public_node
    "#{node.public_path}#{name}/"
  end

  def public_smart_phone_path
    return '' unless node = content.public_node
    "#{node.public_smart_phone_path}#{name}/"
  end

  def public_uri
    return '' unless node = content.public_node
    "#{node.public_uri}#{name}/"
  end

  def public_full_uri
    return '' unless node = content.public_node
    "#{node.public_full_uri}#{name}/"
  end

  def bread_crumbs(category_type_node)
    crumbs = []

    if content
      if (node = content.public_node)
        c = node.bread_crumbs.crumbs.first
        c << [title, "#{node.public_uri}#{name}/"]
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

  def unique_sort_key
    '__%032d_%32s' % [self.sort_no.to_i, self.name.to_s]
  end

  private

  def clean_published_files
    return if !destroyed? && state_public?
    FileUtils.rm_r(public_path) if public_path.present? && ::File.exist?(public_path)
    FileUtils.rm_r(public_smart_phone_path) if public_smart_phone_path.present? && ::File.exist?(public_smart_phone_path)
  end

  class << self
    def public_docs_for_template_module(categoty_type, template_module, mobile: false)
      category_ids = case template_module.module_type
                     when 'docs_1', 'docs_3', 'docs_5', 'docs_7', 'docs_8'
                       categoty_type.public_categories.map(&:id)
                     else
                       []
                     end
      docs = GpArticle::Doc.categorized_into(category_ids).except(:order).mobile(mobile).public_state
      docs = docs.where(content_id: template_module.gp_article_content_ids) if template_module.gp_article_content_ids.present?
      docs
    end
  end
end
