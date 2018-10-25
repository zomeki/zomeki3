class RemoveUnidFromCmsKanaDictionaries < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_kana_dictionaries, :unid, :integer
  end
end
