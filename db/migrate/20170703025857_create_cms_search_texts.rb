class CreateCmsSearchTexts < ActiveRecord::Migration[5.0]
  def change
    create_table :cms_search_texts do |t|
      t.references :searchable, polymorphic: true, index: true
      t.string     :searchable_column
      t.text       :body
      t.timestamps
    end
  end
end
