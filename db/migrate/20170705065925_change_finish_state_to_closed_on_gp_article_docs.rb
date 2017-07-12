class ChangeFinishStateToClosedOnGpArticleDocs < ActiveRecord::Migration[5.0]
  def change
    execute "update gp_article_docs set state = 'closed' where state = 'finish'"
  end
end
