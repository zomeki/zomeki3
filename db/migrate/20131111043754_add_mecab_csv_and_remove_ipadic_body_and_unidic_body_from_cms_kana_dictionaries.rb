class AddMecabCsvAndRemoveIpadicBodyAndUnidicBodyFromCmsKanaDictionaries < ActiveRecord::Migration
  def change
    add_column :cms_kana_dictionaries, :mecab_csv, :text
    remove_column :cms_kana_dictionaries, :ipadic_body
    remove_column :cms_kana_dictionaries, :unidic_body
  end
end
