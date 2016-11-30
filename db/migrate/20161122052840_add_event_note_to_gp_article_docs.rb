class AddEventNoteToGpArticleDocs < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_article_docs, :event_note, :text
  end
end
