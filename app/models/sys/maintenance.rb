class Sys::Maintenance < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager

  include StateText

  validates_presence_of :state, :published_at, :title, :body
end
