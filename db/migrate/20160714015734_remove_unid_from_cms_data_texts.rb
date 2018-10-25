class RemoveUnidFromCmsDataTexts < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_data_texts, :unid, :integer
  end
end
