class RemoveUnidFromCmsDataTexts < ActiveRecord::Migration
  def change
    remove_column :cms_data_texts, :unid, :integer
  end
end
