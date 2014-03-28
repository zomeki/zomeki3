class AddIdToSysUsersGroups < ActiveRecord::Migration
  def change
    add_column :sys_users_groups, :id, :primary_key
  end
end
