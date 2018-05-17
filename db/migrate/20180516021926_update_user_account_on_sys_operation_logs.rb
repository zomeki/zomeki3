class UpdateUserAccountOnSysOperationLogs < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      update sys_operation_logs set user_account = 
        (select account from sys_users where sys_users.id = sys_operation_logs.user_id)
    SQL
  end

  def down
  end
end
