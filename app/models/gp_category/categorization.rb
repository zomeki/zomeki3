class GpCategory::Categorization < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  default_scope { order(:sort_no, :id) }

  belongs_to :categorizable, polymorphic: true
  belongs_to :category

  define_site_scope :categorizable
end
