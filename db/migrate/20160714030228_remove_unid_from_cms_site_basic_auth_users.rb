class RemoveUnidFromCmsSiteBasicAuthUsers < ActiveRecord::Migration
  def change
    remove_column :cms_site_basic_auth_users, :unid, :integer
  end
end
