class SetGroupIdOnSysEditableGroups < ActiveRecord::Migration
  def up
    Sys::EditableGroup.where(group_ids: '', all: false).delete_all

    Sys::EditableGroup.all.each do |eg|
      base_attrs = eg.attributes.except('id', 'group_ids', 'all')
      Sys::EditableGroup.create(base_attrs.merge(group_id: 0)) if eg.all
      eg.group_ids.to_s.split(' ').each do |gid|
        Sys::EditableGroup.create(base_attrs.merge(group_id: gid))
      end
      eg.destroy
    end
  end
end
