class RemoveUnidFromCmsDataFileNodes < ActiveRecord::Migration
  def change
    remove_column :cms_data_file_nodes, :unid, :integer
  end
end
