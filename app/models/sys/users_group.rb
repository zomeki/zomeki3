class Sys::UsersGroup < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager

  belongs_to :user, :foreign_key => :user_id, :class_name => 'Sys::User'
  belongs_to :group, :foreign_key => :group_id, :class_name => 'Sys::Group'
  has_many :site_belongings, class_name: 'Cms::SiteBelonging', primary_key: :group_id, foreign_key: :group_id
end
