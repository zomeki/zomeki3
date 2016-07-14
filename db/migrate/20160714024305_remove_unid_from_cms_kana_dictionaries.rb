class RemoveUnidFromCmsKanaDictionaries < ActiveRecord::Migration
  def change
    remove_column :cms_kana_dictionaries, :unid, :integer
  end
end
