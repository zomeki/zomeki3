class Cms::SiteBasicAuthUser < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager

  scope :root_location, -> {
          where(target_type: 'all')
        }
  scope :system_location, -> {
          where(target_type: '_system')
        }
  scope :directory_location, -> {
          where(target_type: 'directory')
        }
  scope :enabled, -> {
          where(state: 'enabled')
        }
  scope :directory_auth, -> {
    select(:target_location).directory_location
    .enabled.group(:target_location)
    .except(:order).order(:target_location)
  }

  after_initialize :set_defaults

  include StateText

  validates :site_id, :state, :name, :password, presence: true
  validates :target_location, presence: {message: :blank},
    format: { with: /\A[0-9A-Za-z@\.\-_\+\s]+\z/, message: :not_a_filename },
    if: %Q(is_directory?)

  TARGET_TYPE_LIST = [['サイト全体','all'],['管理画面','_system'],['ディレクトリ','directory'],]

  def states
    [['有効','enabled'],['無効','disabled']]
  end

  def target_type_label
    TARGET_TYPE_LIST.each{|a| return a[0] if a[1] == target_type }
    return nil
  end

  def is_directory?
    target_type == 'directory'
  end
  private

  def set_defaults
    self.target_type    ||= TARGET_TYPE_LIST.first.last if self.has_attribute?(:target_type)
  end

end
