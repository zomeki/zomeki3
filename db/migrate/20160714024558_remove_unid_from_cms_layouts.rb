class RemoveUnidFromCmsLayouts < ActiveRecord::Migration
  def change
    remove_column :cms_layouts, :unid, :integer
  end
end
