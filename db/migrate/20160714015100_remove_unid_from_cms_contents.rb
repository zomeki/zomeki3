class RemoveUnidFromCmsContents < ActiveRecord::Migration
  def change
    remove_column :cms_contents, :unid, :integer
  end
end
