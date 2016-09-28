class AddLangToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :lang, :string
  end
end
