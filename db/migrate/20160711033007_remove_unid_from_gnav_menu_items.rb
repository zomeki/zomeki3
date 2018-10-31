class RemoveUnidFromGnavMenuItems < ActiveRecord::Migration[4.2]
  def change
    remove_column :gnav_menu_items, :unid, :integer
  end
end
