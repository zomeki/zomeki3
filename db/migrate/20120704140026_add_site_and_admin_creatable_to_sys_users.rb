class AddSiteAndAdminCreatableToSysUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :sys_users, :admin_creatable, :boolean, :default => false
    add_column :sys_users, :site_creatable, :boolean, :default => false
  end
end
