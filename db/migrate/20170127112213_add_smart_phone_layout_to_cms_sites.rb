class AddSmartPhoneLayoutToCmsSites < ActiveRecord::Migration[5.0]
  def change
    add_column :cms_sites, :smart_phone_layout, :string
  end
end
