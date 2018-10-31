class AddBodyMoreAndBodyMoreLinkTextToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :body_more, :text
    add_column :gp_article_docs, :body_more_link_text, :string
  end
end
