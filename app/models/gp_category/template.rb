class GpCategory::Template < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  #TODO: migrate to strong_parameters
  #attr_accessible :name, :title, :body

  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCategory::Content::CategoryType'
  validates :content_id, presence: true

  validates :name, presence: true, uniqueness: { scope: :content_id }
  validates :title, presence: true

  def containing_modules
    body.scan(/\[\[module\/([\w-]+)\]\]/).map{|m| content.template_modules.find_by(name: m.first) }.compact
  end
end
