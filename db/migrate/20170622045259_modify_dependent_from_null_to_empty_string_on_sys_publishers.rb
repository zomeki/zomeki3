class ModifyDependentFromNullToEmptyStringOnSysPublishers < ActiveRecord::Migration[5.0]
  def up
    execute "update sys_publishers set dependent = '' where dependent is null"
    execute "update cms_talk_tasks set dependent = '' where dependent is null"
  end
  def down
  end
end
