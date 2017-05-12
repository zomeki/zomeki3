class SetStateOnSysTasks < ActiveRecord::Migration[5.0]
  def up
    execute "update sys_tasks set state = 'queued'"
  end
  def down
  end
end
