class GpCategory::Categorization < ApplicationRecord
  include Sys::Model::Base

  default_scope { order(:sort_no) }

  belongs_to :categorizable, polymorphic: true
  belongs_to :category

  nested_scope :in_site, through: :categorizable
end
