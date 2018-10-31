class RemoveItemUnidFromSysOperationLogs < ActiveRecord::Migration[4.2]
  def change
    remove_column :sys_operation_logs, :item_unid, :integer
  end
end
