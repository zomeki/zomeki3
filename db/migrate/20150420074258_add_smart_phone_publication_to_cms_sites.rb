class AddSmartPhonePublicationToCmsSites < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_sites, :smart_phone_publication, :string
  end
end
