class AddSiteIdToSysProcesses < ActiveRecord::Migration[4.2]
  def change
    add_column :sys_processes, :site_id, :integer
    add_column :sys_process_logs, :site_id, :integer
  end
end
