class AddGroupIdToSysEditableGroups < ActiveRecord::Migration
  def change
    add_column :sys_editable_groups, :group_id, :integer
    add_index :sys_editable_groups, :group_id
  end
end
