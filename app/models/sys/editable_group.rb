class Sys::EditableGroup < ApplicationRecord
  include Sys::Model::Base

  ALL_GROUP = 0

  belongs_to :editable, polymorphic: true
  belongs_to :group

  nested_scope :in_site, through: :editable

  def all_group?
    group_id == ALL_GROUP
  end
end
