class RemoveUnidFromSysGroups < ActiveRecord::Migration[4.2]
  def change
    remove_column :sys_groups, :unid, :integer
  end
end
