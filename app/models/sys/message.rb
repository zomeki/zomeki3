class Sys::Message < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Site

  include StateText

  belongs_to :site, class_name: 'Cms::Site'

  validates :state, :published_at, :title, :body, presence: true
end
