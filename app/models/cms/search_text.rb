class Cms::SearchText < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  belongs_to :searchable, polymorphic: true

  define_site_scope :searchable
end
