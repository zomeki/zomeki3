class ChangeBodyOnGpArticleDocs < ActiveRecord::Migration[4.2]
  def up
    change_column :gp_article_docs, :body, :text
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
