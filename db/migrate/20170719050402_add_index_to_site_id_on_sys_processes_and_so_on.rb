class AddIndexToSiteIdOnSysProcessesAndSoOn < ActiveRecord::Migration[5.0]
  def change
    add_index :sys_operation_logs, :site_id
    add_index :sys_processes, :site_id
    add_index :sys_publishers, :path
    add_index :cms_talk_tasks, :site_id
  end
end
