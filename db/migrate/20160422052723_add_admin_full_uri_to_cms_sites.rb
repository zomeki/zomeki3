class AddAdminFullUriToCmsSites < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_sites , :admin_full_uri, :string
  end
end
