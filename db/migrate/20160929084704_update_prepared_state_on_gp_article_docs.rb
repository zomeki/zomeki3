class UpdatePreparedStateOnGpArticleDocs < ActiveRecord::Migration
  def up
    execute <<-SQL
      update gp_article_docs set state = 'prepared' from sys_tasks
        where sys_tasks.processable_type = 'GpArticle::Doc' and sys_tasks.processable_id = gp_article_docs.id
    SQL
  end
end
