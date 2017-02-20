class AddExtraOptionsToSysProcesses < ActiveRecord::Migration[5.0]
  def change
    add_column :sys_processes, :extra_options, :jsonb, default: {}
  end
end
