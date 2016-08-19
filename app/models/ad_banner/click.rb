class AdBanner::Click < ActiveRecord::Base
  include Sys::Model::Base

  default_scope { order(created_at: :desc) }

  belongs_to :banner, :foreign_key => :banner_id, :class_name => 'AdBanner::Banner'
  validates :banner_id, presence: true
end
