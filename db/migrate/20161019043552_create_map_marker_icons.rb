class CreateMapMarkerIcons < ActiveRecord::Migration[5.0]
  def change
    create_table :map_marker_icons do |t|
      t.references :content, index: true
      t.references :relatable, polymorphic: true, index: true
      t.string     :url
      t.timestamps null: false
    end
  end
end
