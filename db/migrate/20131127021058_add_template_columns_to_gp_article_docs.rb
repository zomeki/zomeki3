class AddTemplateColumnsToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :template_id, :integer
    add_column :gp_article_docs, :template_values, :text
  end
end
