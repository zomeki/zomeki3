class RemoveUnidFromCmsSites < ActiveRecord::Migration
  def change
    remove_column :cms_sites, :unid, :integer
  end
end
