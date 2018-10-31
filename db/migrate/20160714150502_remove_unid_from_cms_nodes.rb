class RemoveUnidFromCmsNodes < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_nodes, :unid, :integer
  end
end
