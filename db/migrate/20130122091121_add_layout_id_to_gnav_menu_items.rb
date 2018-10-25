class AddLayoutIdToGnavMenuItems < ActiveRecord::Migration[4.2]
  def change
    add_column :gnav_menu_items, :layout_id, :integer
    add_index :gnav_menu_items, :layout_id
  end
end
