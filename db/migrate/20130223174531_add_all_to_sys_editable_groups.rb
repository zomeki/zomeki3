class AddAllToSysEditableGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :sys_editable_groups, :all, :boolean
  end
end
