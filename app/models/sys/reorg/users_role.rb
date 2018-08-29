class Sys::Reorg::UsersRole < ApplicationRecord
  include Sys::Model::Base

  belongs_to :user
  belongs_to :role_name, foreign_key: :role_id, class_name: 'Sys::RoleName'

  nested_scope :in_site, through: :user
end
