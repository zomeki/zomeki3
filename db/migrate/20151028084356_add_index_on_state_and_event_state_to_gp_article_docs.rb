class AddIndexOnStateAndEventStateToGpArticleDocs < ActiveRecord::Migration
  def change
    add_index :gp_article_docs, :state
    add_index :gp_article_docs, :terminal_pc_or_smart_phone
    add_index :gp_article_docs, :event_state
    add_index :gp_article_docs, [:event_started_on, :event_ended_on]
  end
end
