class AddPublishedAtToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :published_at, :datetime
  end
end
