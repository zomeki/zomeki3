class RemoveUnidFromSysPublishers < ActiveRecord::Migration[4.2]
  def change
    remove_column :sys_publishers, :unid, :integer
  end
end
