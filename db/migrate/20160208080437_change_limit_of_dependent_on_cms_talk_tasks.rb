class ChangeLimitOfDependentOnCmsTalkTasks < ActiveRecord::Migration
  def up
    change_column :cms_talk_tasks, :dependent, :string
  end
  def down
    change_column :cms_talk_tasks, :dependent, :string
  end
end
