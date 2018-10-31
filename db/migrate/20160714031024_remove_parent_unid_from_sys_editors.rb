class RemoveParentUnidFromSysEditors < ActiveRecord::Migration[4.2]
  def change
    remove_column :sys_editors, :parent_unid, :integer
  end
end
