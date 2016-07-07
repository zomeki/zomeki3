class RemoveUnidFromGpArticleDocs < ActiveRecord::Migration
  def change
    remove_column :gp_article_docs, :unid, :integer
  end
end
