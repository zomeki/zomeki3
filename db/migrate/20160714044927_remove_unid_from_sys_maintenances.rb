class RemoveUnidFromSysMaintenances < ActiveRecord::Migration[4.2]
  def change
    remove_column :sys_maintenances, :unid, :integer
  end
end
