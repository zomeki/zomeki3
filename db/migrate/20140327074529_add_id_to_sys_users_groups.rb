class AddIdToSysUsersGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :sys_users_groups, :id, :primary_key
  end
end
