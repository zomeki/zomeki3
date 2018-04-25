class Sys::Maintenance < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager

  column_attribute :body, html: true

  enum_ish :state, [:public, :closed]

  validates :state, :published_at, :title, :body, presence: true
end
