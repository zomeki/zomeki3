class AddCreatorIdToGpArticleDocs < ActiveRecord::Migration
  def up
    add_column :gp_article_docs, :creator_id, :integer, index: true
    GpArticle::Doc.find_each {|d| d.update_column(:creator_id, d.unid) }
  end

  def down
    remove_column :gp_article_docs, :creator_id
  end
end
