class ChangeSubtitleAndSummaryOnGpArticleDocs < ActiveRecord::Migration[4.2]
  def up
    change_column :gp_article_docs, :subtitle, :text
    change_column :gp_article_docs, :summary, :text
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
