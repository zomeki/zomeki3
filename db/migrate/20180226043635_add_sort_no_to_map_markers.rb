class AddSortNoToMapMarkers < ActiveRecord::Migration[5.0]
  def change
    add_column :map_markers, :sort_no, :integer
  end
end
