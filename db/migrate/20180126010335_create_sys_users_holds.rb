class CreateSysUsersHolds < ActiveRecord::Migration[5.0]
  def change
    create_table :sys_users_holds do |t|
      t.references :user
      t.references :holdable, polymorphic: true
      t.string     :session_id
      t.timestamps
    end
  end
end
