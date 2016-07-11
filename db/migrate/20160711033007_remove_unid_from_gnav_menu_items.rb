class RemoveUnidFromGnavMenuItems < ActiveRecord::Migration
  def change
    remove_column :gnav_menu_items, :unid, :integer
  end
end
