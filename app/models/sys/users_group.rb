class Sys::UsersGroup < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site
  include Cms::Model::Auth::Site::User

  belongs_to :user
  belongs_to :group
  has_many :site_belongings, class_name: 'Cms::SiteBelonging', primary_key: :group_id, foreign_key: :group_id

  define_site_scope :group
end
