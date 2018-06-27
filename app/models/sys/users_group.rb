class Sys::UsersGroup < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Auth::Site::User

  belongs_to :user
  belongs_to :group
  has_many :site_belongings, class_name: 'Cms::SiteBelonging', primary_key: :group_id, foreign_key: :group_id

  validates :group_id, presence: true

  nested_scope :in_site, through: :group

  class << self
    def group_options(site)
      site.groups_for_option
    end
  end
end
