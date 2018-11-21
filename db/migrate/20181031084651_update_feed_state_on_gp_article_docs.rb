class UpdateFeedStateOnGpArticleDocs < ActiveRecord::Migration[5.0]
  def up
    execute "update gp_article_docs set feed_state = 'visible' where feature_1 = 't'"
    execute "update gp_article_docs set feed_state = 'hidden' where feature_1 = 'f'"
  end

  def down
  end
end
