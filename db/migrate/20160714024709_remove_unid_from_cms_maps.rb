class RemoveUnidFromCmsMaps < ActiveRecord::Migration
  def change
    remove_column :cms_maps, :unid, :integer
  end
end
