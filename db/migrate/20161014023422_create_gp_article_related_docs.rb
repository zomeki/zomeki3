class CreateGpArticleRelatedDocs < ActiveRecord::Migration
  def up
    create_table :gp_article_related_docs do |t|
      t.integer :content_id
      t.integer :relatable_id
      t.string  :relatable_type
      t.string  :name
      t.timestamps null: false
    end
    doc_with_related_docs = GpArticle::Doc.where.not(GpArticle::Doc.arel_table[:rel_doc_ids].eq(nil))
    doc_with_related_docs.each do |doc|
      rel_docs = doc.rel_docs
      rel_docs.each{|d| doc.related_docs.create(content_id: d.content_id, name: d.name)}
    end
  end

  def down
    drop_table :gp_article_related_docs
  end
end
