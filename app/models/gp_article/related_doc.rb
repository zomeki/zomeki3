class GpArticle::RelatedDoc < ActiveRecord::Base
  include Sys::Model::Base

  # Content
  belongs_to :content, foreign_key: :content_id, class_name: 'GpArticle::Content::Doc'
  validates :content_id, presence: true

  belongs_to :relatable, polymorphic: true

  has_one :target_doc, foreign_key: :name, primary_key: :name, class_name: 'GpArticle::Doc'

end
