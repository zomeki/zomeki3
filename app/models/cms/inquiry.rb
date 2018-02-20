class Cms::Inquiry < ApplicationRecord
  include Sys::Model::Base

  enum_ish :state, [:visible, :hidden]

  belongs_to :inquirable, polymorphic: true
  belongs_to :group, class_name: 'Sys::Group'

  delegate :address, to: :group, allow_nil: true
  delegate :tel, to: :group, allow_nil: true
  delegate :tel_attend, to: :group, allow_nil: true
  delegate :fax, to: :group, allow_nil: true
  delegate :email, to: :group, allow_nil: true
  delegate :note, to: :group, allow_nil: true

  nested_scope :in_site, through: :inquirable

  def visible?
    state == 'visible'
  end
end
