class RemoveUnidFromSysObjectPrivileges < ActiveRecord::Migration
  def change
    remove_column :sys_object_privileges, :item_unid, :integer
  end
end
