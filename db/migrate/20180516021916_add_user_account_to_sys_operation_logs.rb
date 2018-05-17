class AddUserAccountToSysOperationLogs < ActiveRecord::Migration[5.0]
  def change
    add_column :sys_operation_logs, :user_account, :string
  end
end
