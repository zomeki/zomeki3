class AddPrevEditionIdToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :prev_edition_id, :integer
  end
end
