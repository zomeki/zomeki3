module Cms::Model::Rel::ContentModel
  extend ActiveSupport::Concern

  included do
    belongs_to :content, foreign_key: :content_id, class_name: 'Cms::Content'
  end

  def content_name
    content ? content.name : Cms::Lib::Modules.module_name(:cms)
  end

  def content
    c = super
    c.becomes(c.model.split('::').insert(1, 'Content').join('::').constantize)
  rescue NameError
    c
  end
end
