class RemoveUnidFromSysFiles < ActiveRecord::Migration[4.2]
  def change
    remove_column :sys_files, :unid, :integer
    remove_column :sys_files, :parent_unid, :integer
  end
end
