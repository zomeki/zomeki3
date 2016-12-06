class Relation::Doc < ApplicationRecord
  include Sys::Model::Base

  # Content
  belongs_to :content, foreign_key: :content_id, class_name: 'GpArticle::Content::Doc'
  validates :content_id, presence: true

  belongs_to :relatable, polymorphic: true

  def target_doc
    GpArticle::Doc.where(name: name, content_id: target_content_id).first
  end
end
