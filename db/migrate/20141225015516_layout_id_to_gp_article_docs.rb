class LayoutIdToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :layout_id, :integer
  end
end
