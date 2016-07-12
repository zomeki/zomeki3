class RemoveUnidFromMapMarkers < ActiveRecord::Migration
  def change
    remove_column :map_markers, :unid, :integer
  end
end
