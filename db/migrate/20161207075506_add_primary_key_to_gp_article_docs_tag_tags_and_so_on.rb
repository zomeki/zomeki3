class AddPrimaryKeyToGpArticleDocsTagTagsAndSoOn < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_article_docs_tag_tags, :id, :primary_key
    add_column :gp_calendar_events_gp_category_categories, :id, :primary_key
  end
end
