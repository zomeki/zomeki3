class AddNameToMapMarkers < ActiveRecord::Migration[4.2]
  def change
    add_column :map_markers, :name, :string
  end
end
