class GpArticle::Link < ActiveRecord::Base
  include Sys::Model::Base

  validates :doc_id, :presence => true

  belongs_to :doc
end
