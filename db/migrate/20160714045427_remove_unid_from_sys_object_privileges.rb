class RemoveUnidFromSysObjectPrivileges < ActiveRecord::Migration[4.2]
  def change
    remove_column :sys_object_privileges, :item_unid, :integer
  end
end
