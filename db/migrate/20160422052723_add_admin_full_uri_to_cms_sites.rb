class AddAdminFullUriToCmsSites < ActiveRecord::Migration
  def change
    add_column :cms_sites , :admin_full_uri, :string
  end
end
