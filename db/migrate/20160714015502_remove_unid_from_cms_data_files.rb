class RemoveUnidFromCmsDataFiles < ActiveRecord::Migration
  def change
    remove_column :cms_data_files, :unid, :integer
  end
end
