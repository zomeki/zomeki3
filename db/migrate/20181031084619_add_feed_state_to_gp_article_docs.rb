class AddFeedStateToGpArticleDocs < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_article_docs, :feed_state, :string
  end
end
