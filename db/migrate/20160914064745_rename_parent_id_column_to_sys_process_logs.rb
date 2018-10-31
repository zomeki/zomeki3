class RenameParentIdColumnToSysProcessLogs < ActiveRecord::Migration[4.2]
  def change
    rename_column :sys_process_logs, :parent_id, :process_id
  end
end
