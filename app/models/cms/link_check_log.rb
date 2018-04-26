class Cms::LinkCheckLog < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Site

  column_attribute :checked, default: false

  enum_ish :result_state, [:success, :failure, :skip]

  belongs_to :link_checkable, polymorphic: true
end
