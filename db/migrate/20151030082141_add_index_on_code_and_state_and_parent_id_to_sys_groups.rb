class AddIndexOnCodeAndStateAndParentIdToSysGroups < ActiveRecord::Migration[4.2]
  def change
    add_index :sys_groups, :code
    add_index :sys_groups, :state
    add_index :sys_groups, :parent_id
  end
end
