class RemoveUnidFromCmsMaps < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_maps, :unid, :integer
  end
end
