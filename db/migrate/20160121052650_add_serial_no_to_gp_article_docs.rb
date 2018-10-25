class AddSerialNoToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :serial_no, :integer
  end
end
