class AddPrivilegableToSysObjectPrivileges < ActiveRecord::Migration
  def up
    add_column :sys_object_privileges, :privilegable_id, :integer
    add_column :sys_object_privileges, :privilegable_type, :string
    add_index :sys_object_privileges, [:privilegable_type, :privilegable_id], name: 'index_sys_object_privileges_on_privilegable'
    Sys::ObjectPrivilege.find_each do |op|
      unid = Sys::Unid.find(op.item_unid)
      target = unid.model.constantize.find(unid.item_id)
      op.privilegable = target
      op.save
    end
  end

  def down
    remove_index :sys_object_privileges, name: 'index_sys_object_privileges_on_privilegable'
    remove_column :sys_object_privileges, :privilegable_type
    remove_column :sys_object_privileges, :privilegable_id
  end
end
