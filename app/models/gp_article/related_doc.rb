class GpArticle::RelatedDoc < ApplicationRecord
  include Sys::Model::Base

  # Content
  belongs_to :content, class_name: 'GpArticle::Content::Doc', required: true

  belongs_to :relatable, polymorphic: true

  nested_scope :in_site, through: :relatable

  def target_doc
    GpArticle::Doc.where(name: name, content_id: content_id).first
  end
end
