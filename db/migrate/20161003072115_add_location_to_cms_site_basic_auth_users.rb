class AddLocationToCmsSiteBasicAuthUsers < ActiveRecord::Migration
  def change
    add_column :cms_site_basic_auth_users, :target_type, :string
    add_column :cms_site_basic_auth_users, :target_location, :string
  end
end
