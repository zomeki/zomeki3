class ChangeListImageOnGpArticleDocs < ActiveRecord::Migration[4.2]
  def up
    change_column :gp_article_docs, :list_image, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
