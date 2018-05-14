class CreateCmsSiteAccessControls < ActiveRecord::Migration[5.0]
  def change
    create_table :cms_site_access_controls do |t|
      t.references :site
      t.string     :state
      t.string     :target_type
      t.string     :target_location
      t.text       :basic_auth
      t.text       :ip_order
      t.text       :ip
      t.timestamps
    end
  end
end
