class CreateGpArticlePublishers < ActiveRecord::Migration
  def change
    create_table :gp_article_publishers do |t|
      t.integer :doc_id, index: true
      t.timestamps
    end
  end
end
