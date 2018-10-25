class AddShareToSnsWithToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :share_to_sns_with, :string
  end
end
