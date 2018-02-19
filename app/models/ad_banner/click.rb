class AdBanner::Click < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  default_scope { order(created_at: :desc) }

  belongs_to :banner, class_name: 'AdBanner::Banner', required: true

  define_site_scope :banner
end
