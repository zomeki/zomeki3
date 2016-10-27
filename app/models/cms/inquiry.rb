class Cms::Inquiry < ApplicationRecord
  include Sys::Model::Base
  include StateText

  belongs_to :group, :foreign_key => :group_id, :class_name => 'Sys::Group'

  delegate :address, to: :group, allow_nil: true
  delegate :tel, to: :group, allow_nil: true
  delegate :tel_attend, to: :group, allow_nil: true
  delegate :fax, to: :group, allow_nil: true
  delegate :email, to: :group, allow_nil: true
  delegate :note, to: :group, allow_nil: true

  def visible?
    state == 'visible'
  end
end
