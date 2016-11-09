class CreateGpArticleDirectories < ActiveRecord::Migration[5.0]
  def change
    create_table :gp_article_directories do |t|
      t.integer :content_id
      t.integer :publishable_id
      t.string  :publishable_type
      t.string  :name
      t.timestamps
    end
  end
end
