class RemoveUnidFromSysPublishers < ActiveRecord::Migration
  def change
    remove_column :sys_publishers, :unid, :integer
  end
end
