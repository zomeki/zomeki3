class ChangeLimitOfDependentOnSysPublishers < ActiveRecord::Migration[4.2]
  def up
    change_column :sys_publishers, :dependent, :string
  end
  def down
    change_column :sys_publishers, :dependent, :string
  end
end
