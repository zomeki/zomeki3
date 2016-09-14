class RenameParentIdColumnToSysProcessLogs < ActiveRecord::Migration
  def change
    rename_column :sys_process_logs, :parent_id, :process_id
  end
end
