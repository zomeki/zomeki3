class AddMarkerStateToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :marker_state, :string
  end
end
