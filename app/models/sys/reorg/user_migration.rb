class Sys::Reorg::UserMigration < ApplicationRecord
  include Sys::Model::Base

  belongs_to :user
  belongs_to :source_user, class_name: 'Sys::Reorg::User'

  nested_scope :in_site, through: :user

  class << self
    def source_user_options(site)
      Sys::Reorg::User.in_site(site).order(:account, :id).map { |u| [u.name_with_account, u.id] }
    end
  end
end
