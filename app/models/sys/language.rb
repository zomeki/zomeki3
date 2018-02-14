class Sys::Language < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager

  enum_ish :state, [:enabled, :disabled]

  validates :state, :name, :title, presence: true
end
