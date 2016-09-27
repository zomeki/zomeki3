class AddSiteIdToSysProcesses < ActiveRecord::Migration
  def change
    add_column :sys_processes, :site_id, :integer
    add_column :sys_process_logs, :site_id, :integer
  end
end
