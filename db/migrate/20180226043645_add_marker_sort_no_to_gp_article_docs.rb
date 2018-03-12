class AddMarkerSortNoToGpArticleDocs < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_article_docs, :marker_sort_no, :integer
  end
end
