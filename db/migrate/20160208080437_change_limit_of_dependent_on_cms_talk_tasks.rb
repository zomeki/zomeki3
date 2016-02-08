class ChangeLimitOfDependentOnCmsTalkTasks < ActiveRecord::Migration
  def up
    change_column :cms_talk_tasks, :dependent, :string, limit: 255
  end
  def down
    change_column :cms_talk_tasks, :dependent, :string, limit: 64
  end
end
