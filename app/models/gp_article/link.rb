class GpArticle::Link < ApplicationRecord
  include Sys::Model::Base

  validates :doc_id, :presence => true

  belongs_to :doc
end
