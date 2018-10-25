class RemoveUnidFromGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    remove_column :gp_article_docs, :unid, :integer
  end
end
