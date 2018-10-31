class RemoveUnidFromCmsTalkTasks < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_talk_tasks, :unid, :integer
  end
end
