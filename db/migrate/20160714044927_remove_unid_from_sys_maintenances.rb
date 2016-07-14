class RemoveUnidFromSysMaintenances < ActiveRecord::Migration
  def change
    remove_column :sys_maintenances, :unid, :integer
  end
end
