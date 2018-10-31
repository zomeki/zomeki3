class AddRecognizedAtToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :recognized_at, :datetime
  end
end
