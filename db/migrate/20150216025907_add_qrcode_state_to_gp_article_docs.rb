class AddQrcodeStateToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :qrcode_state, :text
  end
end
