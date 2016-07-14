class RemoveUnidFromSysTasks < ActiveRecord::Migration
  def change
    remove_column :sys_tasks, :unid, :integer
  end
end
