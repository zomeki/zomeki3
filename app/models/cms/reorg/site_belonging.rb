class Cms::Reorg::SiteBelonging < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Site

  belongs_to :group, class_name: 'Sys::Reorg::Group'

  validates :site_id, presence: true
end
