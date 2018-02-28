class AdBanner::Click < ApplicationRecord
  include Sys::Model::Base

  default_scope { order(created_at: :desc) }

  belongs_to :banner, class_name: 'AdBanner::Banner', required: true

  nested_scope :in_site, through: :banner
end
