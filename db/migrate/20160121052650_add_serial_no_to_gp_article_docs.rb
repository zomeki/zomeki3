class AddSerialNoToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :serial_no, :integer
  end
end
