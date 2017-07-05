class AdBanner::Click < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  default_scope { order(created_at: :desc) }

  belongs_to :banner, :foreign_key => :banner_id, :class_name => 'AdBanner::Banner'
  validates :banner_id, presence: true

  define_site_scope :banner
end
