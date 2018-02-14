class Gnav::CategorySet < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  enum_ish :layer, [:descendants, :self], default: :descendants

  belongs_to :menu_item
  belongs_to :category, :class_name => 'GpCategory::Category'

  define_site_scope :menu_item
end
