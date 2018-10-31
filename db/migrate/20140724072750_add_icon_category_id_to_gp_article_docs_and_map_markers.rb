class AddIconCategoryIdToGpArticleDocsAndMapMarkers < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :marker_icon_category_id, :integer
    add_column :map_markers, :icon_category_id, :integer
  end
end
