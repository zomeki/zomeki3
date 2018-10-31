class AddSitemapStateToGnavMenuItems < ActiveRecord::Migration[4.2]
  def change
    add_column :gnav_menu_items, :sitemap_state, :string
  end
end
