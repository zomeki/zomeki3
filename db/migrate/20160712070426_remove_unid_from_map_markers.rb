class RemoveUnidFromMapMarkers < ActiveRecord::Migration[4.2]
  def change
    remove_column :map_markers, :unid, :integer
  end
end
