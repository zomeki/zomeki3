class AddConceptToSysObjectPrivileges < ActiveRecord::Migration
  def up
    add_column :sys_object_privileges, :concept_id, :integer
    add_index :sys_object_privileges, :concept_id
    add_foreign_key :sys_object_privileges, :cms_concepts, column: :concept_id
    Sys::ObjectPrivilege.find_each do |op|
      op.concept = Cms::Concept.find_by(unid: op.item_unid)
      op.save
    end
  end

  def down
    remove_foreign_key :sys_object_privileges, column: :concept_id
    remove_index :sys_object_privileges, :concept_id
    remove_column :sys_object_privileges, :concept_id
  end
end
