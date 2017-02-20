class AddScriptOptionsToSysProcesses < ActiveRecord::Migration[5.0]
  def change
    add_column :sys_processes, :script_options, :jsonb, default: {}
  end
end
