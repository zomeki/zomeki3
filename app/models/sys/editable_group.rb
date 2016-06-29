class Sys::EditableGroup < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :editable, polymorphic: true, required: true

  def groups
    Sys::Group.where(id: group_ids.to_s.split)
  end
end
