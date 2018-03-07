class CreateSysUsersSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :sys_users_sessions do |t|
      t.references  :user
      t.string      :session_id
      t.timestamps
    end
  end
end
