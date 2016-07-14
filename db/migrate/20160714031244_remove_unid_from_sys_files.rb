class RemoveUnidFromSysFiles < ActiveRecord::Migration
  def change
    remove_column :sys_files, :unid, :integer
    remove_column :sys_files, :parent_unid, :integer
  end
end
