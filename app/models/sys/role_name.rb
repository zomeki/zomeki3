class Sys::RoleName < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Cms::Model::Auth::Site

  has_many :users_roles, :foreign_key => :role_id, :primary_key => :id,
    :class_name => 'Sys::UsersRole', :dependent => :destroy
  has_many :object_privileges, :foreign_key => :role_id,
    :class_name => 'Sys::ObjectPrivilege'

  belongs_to :site, class_name: 'Cms::Site'

  validates :name, :title, presence: true

  scope :search_with_params, ->(params = {}) {
    rel = all
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_keyword'
        rel = rel.search_with_text(:title, :name, v)
      end
    end
    rel
  }
end
