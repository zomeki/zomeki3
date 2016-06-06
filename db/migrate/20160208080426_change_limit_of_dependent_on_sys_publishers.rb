class ChangeLimitOfDependentOnSysPublishers < ActiveRecord::Migration
  def up
    change_column :sys_publishers, :dependent, :string
  end
  def down
    change_column :sys_publishers, :dependent, :string
  end
end
