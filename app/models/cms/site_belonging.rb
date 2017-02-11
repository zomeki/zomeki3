class Cms::SiteBelonging < ApplicationRecord
  include Sys::Model::Base

  belongs_to :site,  :class_name => 'Cms::Site'
  belongs_to :group, :class_name => 'Sys::Group'

  validates :site_id, presence: true
end
