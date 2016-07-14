class RemoveItemUnidFromSysOperationLogs < ActiveRecord::Migration
  def change
    remove_column :sys_operation_logs, :item_unid, :integer
  end
end
