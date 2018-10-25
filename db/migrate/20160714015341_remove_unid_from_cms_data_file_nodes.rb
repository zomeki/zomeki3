class RemoveUnidFromCmsDataFileNodes < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_data_file_nodes, :unid, :integer
  end
end
