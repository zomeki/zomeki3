class GpArticle::RelatedDoc < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  # Content
  belongs_to :content, foreign_key: :content_id, class_name: 'GpArticle::Content::Doc'
  validates :content_id, presence: true

  belongs_to :relatable, polymorphic: true

  define_site_scope :relatable

  def target_doc
    GpArticle::Doc.where(name: name, content_id: content_id).first
  end
end
