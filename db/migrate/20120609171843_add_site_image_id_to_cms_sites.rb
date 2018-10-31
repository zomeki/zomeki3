class AddSiteImageIdToCmsSites < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_sites, :site_image_id, :integer
  end
end
