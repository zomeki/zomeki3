class Cms::SiteBasicAuthUser < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::Creator
  include Cms::Model::Site
  include Cms::Model::Rel::Site
  include Cms::Model::Auth::Site

  enum_ish :state, [:enabled, :disabled]
  enum_ish :target_type, [:all, :_system, :directory], default: :all

  validates :site_id, :state, :name, :password, presence: true
  validates :target_location, presence: true,
                              format: { with: /\A[0-9A-Za-z@\.\-_\+\s\/]+\z/, message: :not_a_filename },
                              if: -> { is_directory? }

  scope :all_location, -> { where(target_type: 'all') }
  scope :system_location, -> { where(target_type: '_system') }
  scope :directory_location, -> { where(target_type: 'directory') }
  scope :enabled, -> { where(state: 'enabled') }

  def is_directory?
    target_type == 'directory'
  end
end
