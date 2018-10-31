class RemoveUnidFromCmsSiteBasicAuthUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_site_basic_auth_users, :unid, :integer
  end
end
