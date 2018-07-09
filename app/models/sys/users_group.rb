class Sys::UsersGroup < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Auth::Site::User

  belongs_to :user
  belongs_to :group

  validates :group_id, presence: true

  nested_scope :in_site, through: :group

  class << self
    def group_options(site)
      site.groups_for_option
    end
  end
end
