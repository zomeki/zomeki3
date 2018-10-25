class AddMecabCsvAndRemoveIpadicBodyAndUnidicBodyFromCmsKanaDictionaries < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_kana_dictionaries, :mecab_csv, :text
    remove_column :cms_kana_dictionaries, :ipadic_body
    remove_column :cms_kana_dictionaries, :unidic_body
  end
end
