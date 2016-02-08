class ChangeLimitOfDependentOnSysPublishers < ActiveRecord::Migration
  def up
    change_column :sys_publishers, :dependent, :string, limit: 255
  end
  def down
    change_column :sys_publishers, :dependent, :string, limit: 64
  end
end
