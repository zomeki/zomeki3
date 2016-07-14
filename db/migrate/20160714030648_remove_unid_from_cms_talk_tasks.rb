class RemoveUnidFromCmsTalkTasks < ActiveRecord::Migration
  def change
    remove_column :cms_talk_tasks, :unid, :integer
  end
end
