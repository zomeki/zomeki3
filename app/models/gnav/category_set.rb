class Gnav::CategorySet < ApplicationRecord
  include Sys::Model::Base

  enum_ish :layer, [:descendants, :self], default: :descendants

  belongs_to :menu_item
  belongs_to :category, class_name: 'GpCategory::Category'

  delegate :category_type, to: :category

  nested_scope :in_site, through: :menu_item
end
