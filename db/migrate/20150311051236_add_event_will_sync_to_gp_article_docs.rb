class AddEventWillSyncToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :event_will_sync, :string
  end
end
