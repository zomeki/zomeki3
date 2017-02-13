class ReplaceNameOnSysProcesses2 < ActiveRecord::Migration[5.0]
  def up
    map = [
      ['sys/script/tasks/exec', 'sys/tasks/exec'],
    ]
    map.each do |before, after|
      execute "update sys_processes set name = replace(name, '#{before}', '#{after}')"
      execute "update sys_process_logs set name = replace(name, '#{before}', '#{after}')"
    end
  end
end
