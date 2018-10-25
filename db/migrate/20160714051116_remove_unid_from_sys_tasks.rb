class RemoveUnidFromSysTasks < ActiveRecord::Migration[4.2]
  def change
    remove_column :sys_tasks, :unid, :integer
  end
end
