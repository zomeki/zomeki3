class CreateRelationDocs < ActiveRecord::Migration[5.0]
  def change
    create_table :relation_docs do |t|
      t.integer :content_id
      t.integer :relatable_id
      t.string  :relatable_type
      t.integer :relatble_content_id
      t.string  :target_content_id
      t.string  :name
      t.timestamps null: false
    end
  end
end
