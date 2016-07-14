class RemoveUnidFromSysGroups < ActiveRecord::Migration
  def change
    remove_column :sys_groups, :unid, :integer
  end
end
