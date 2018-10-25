class RemoveUnidFromCmsDataFiles < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_data_files, :unid, :integer
  end
end
