class RemoveUnidFromCmsNodes < ActiveRecord::Migration
  def change
    remove_column :cms_nodes, :unid, :integer
  end
end
