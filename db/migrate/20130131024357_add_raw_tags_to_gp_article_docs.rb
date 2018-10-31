class AddRawTagsToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :raw_tags, :text
  end
end
