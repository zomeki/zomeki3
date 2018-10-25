class AddGroupIdToSysEditableGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :sys_editable_groups, :group_id, :integer
    add_index :sys_editable_groups, :group_id
  end
end
