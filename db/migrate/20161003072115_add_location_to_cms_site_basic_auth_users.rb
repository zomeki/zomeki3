class AddLocationToCmsSiteBasicAuthUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_site_basic_auth_users, :target_type, :string
    add_column :cms_site_basic_auth_users, :target_location, :string
  end
end
