class AddIndexOnUserIdAndSessionIdToSysUsersSessions < ActiveRecord::Migration[5.0]
  def change
    add_index :sys_users_sessions, [:user_id, :session_id], unique: true
  end
end
