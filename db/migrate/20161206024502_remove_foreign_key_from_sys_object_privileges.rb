class RemoveForeignKeyFromSysObjectPrivileges < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :sys_object_privileges, column: :concept_id
  end
end
