class AddIndexOnCodeAndStateAndParentIdToSysGroups < ActiveRecord::Migration
  def change
    add_index :sys_groups, :code
    add_index :sys_groups, :state
    add_index :sys_groups, :parent_id
  end
end
