class AddRelDocIdsToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :rel_doc_ids, :string
  end
end
