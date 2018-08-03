class AddNavigationStateToGpArticleDocs < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_article_docs, :navigation_state, :string
  end
end
