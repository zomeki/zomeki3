class Sys::EditableGroup < ActiveRecord::Base
  include Sys::Model::Base
  
  def groups
    ids = group_ids.to_s.split(' ').uniq
    ids.blank? ? [] : Sys::Group.where(id: ids).to_a
  end
end
