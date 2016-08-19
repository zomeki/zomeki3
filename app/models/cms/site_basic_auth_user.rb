class Cms::SiteBasicAuthUser < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager

  include StateText

  validates :site_id, :state, :name, :password, presence: true

  def states
    [['有効','enabled'],['無効','disabled']]
  end
end
