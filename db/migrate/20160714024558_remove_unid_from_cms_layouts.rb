class RemoveUnidFromCmsLayouts < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_layouts, :unid, :integer
  end
end
