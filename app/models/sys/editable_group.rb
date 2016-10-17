class Sys::EditableGroup < ApplicationRecord
  include Sys::Model::Base

  ALL_GROUP = 0

  belongs_to :editable, polymorphic: true
  belongs_to :group, class_name: 'Sys::Group'

  def all_group?
    group_id == ALL_GROUP
  end
end
