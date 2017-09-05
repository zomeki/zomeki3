class AddRemarkToGpArticleDocs < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_article_docs, :remark, :text
  end
end
