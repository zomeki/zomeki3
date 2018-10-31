class ChangeLimitOfDependentOnCmsTalkTasks < ActiveRecord::Migration[4.2]
  def up
    change_column :cms_talk_tasks, :dependent, :string
  end
  def down
    change_column :cms_talk_tasks, :dependent, :string
  end
end
