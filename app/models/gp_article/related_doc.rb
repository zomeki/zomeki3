class GpArticle::RelatedDoc < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  # Content
  belongs_to :content, class_name: 'GpArticle::Content::Doc', required: true

  belongs_to :relatable, polymorphic: true

  define_site_scope :relatable

  def target_doc
    GpArticle::Doc.where(name: name, content_id: content_id).first
  end
end
