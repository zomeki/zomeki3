class CreateGpArticleLinks < ActiveRecord::Migration[4.2]
  def change
    create_table :gp_article_links do |t|
      t.belongs_to :doc

      t.string :body
      t.string :url

      t.timestamps
    end
  end
end
