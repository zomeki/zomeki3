class RemoveParentUnidFromSysEditors < ActiveRecord::Migration
  def change
    remove_column :sys_editors, :parent_unid, :integer
  end
end
