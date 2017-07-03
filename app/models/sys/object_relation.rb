class Sys::ObjectRelation < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  belongs_to :source, polymorphic: true, required: true
  belongs_to :related, polymorphic: true, required: true

  define_site_scope :source
end
