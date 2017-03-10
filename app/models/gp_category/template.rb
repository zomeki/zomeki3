class GpCategory::Template < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCategory::Content::CategoryType'
  validates :content_id, presence: true

  has_many :category_types
  has_many :categories

  after_save     GpCategory::Publisher::TemplateCallbacks.new, if: :changed?
  before_destroy GpCategory::Publisher::TemplateCallbacks.new

  validates :name, presence: true, uniqueness: { scope: :content_id }
  validates :title, presence: true

  def public_category_types
    category_types.where(state: 'public')
  end

  def public_categories
    categories.where(state: 'public')
  end

  def containing_modules
    body.scan(/\[\[module\/([\w-]+)\]\]/).map{|m| content.template_modules.find_by(name: m.first) }.compact
  end
end
