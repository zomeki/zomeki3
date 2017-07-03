class GpArticle::DocsTagTag < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  belongs_to :doc, class_name: 'GpArticle::Doc'
  belongs_to :tag, class_name: 'Tag::Tag'

  define_site_scope :doc
end
