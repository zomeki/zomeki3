class DropObsoleteTables < ActiveRecord::Migration
  def up
    drop_table :article_areas, if_exists: true
    drop_table :article_attributes, if_exists: true
    drop_table :article_categories, if_exists: true
    drop_table :article_docs, if_exists: true
    drop_table :article_tags, if_exists: true
    drop_table :bbs_items, if_exists: true
    drop_table :calendar_events, if_exists: true
    drop_table :enquete_answers, if_exists: true
    drop_table :enquete_answer_columns, if_exists: true
    drop_table :enquete_forms, if_exists: true
    drop_table :enquete_form_columns, if_exists: true
    drop_table :laby_docs, if_exists: true
    drop_table :newsletter_delivery_logs, if_exists: true
    drop_table :newsletter_docs, if_exists: true
    drop_table :newsletter_members, if_exists: true
    drop_table :newsletter_requests, if_exists: true
    drop_table :newsletter_tests, if_exists: true
    drop_table :portal_article_categories, if_exists: true
    drop_table :portal_article_docs, if_exists: true
    drop_table :portal_article_tags, if_exists: true
    drop_table :portal_calendar_events, if_exists: true
    drop_table :portal_calendar_genres, if_exists: true
    drop_table :portal_calendar_statuses, if_exists: true
    drop_table :portal_categories, if_exists: true
    drop_table :portal_group_areas, if_exists: true
    drop_table :portal_group_attributes, if_exists: true
    drop_table :portal_group_businesses, if_exists: true
    drop_table :portal_group_categories, if_exists: true
    drop_table :public_bbs_categories, if_exists: true
    drop_table :public_bbs_responses, if_exists: true
    drop_table :public_bbs_tags, if_exists: true
    drop_table :public_bbs_threads, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
