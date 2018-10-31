class RemoveUnidFromCmsSites < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_sites, :unid, :integer
  end
end
