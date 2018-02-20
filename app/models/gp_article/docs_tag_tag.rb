class GpArticle::DocsTagTag < ApplicationRecord
  include Sys::Model::Base

  belongs_to :doc, class_name: 'GpArticle::Doc'
  belongs_to :tag, class_name: 'Tag::Tag'

  nested_scope :in_site, through: :doc
end
