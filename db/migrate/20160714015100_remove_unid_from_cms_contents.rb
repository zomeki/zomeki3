class RemoveUnidFromCmsContents < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_contents, :unid, :integer
  end
end
