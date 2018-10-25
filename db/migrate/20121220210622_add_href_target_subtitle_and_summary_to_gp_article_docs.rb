class AddHrefTargetSubtitleAndSummaryToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :href, :string
    add_column :gp_article_docs, :target, :string
    add_column :gp_article_docs, :subtitle, :string
    add_column :gp_article_docs, :summary, :string
  end
end
