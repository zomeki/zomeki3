class AddEventStateAndEventDateToGpArticleDocs < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_article_docs, :event_state, :string
    add_column :gp_article_docs, :event_date, :date
  end
end
