class UpdateNameOfSysProcessesForGpArticleDocs < ActiveRecord::Migration[5.0]
  def change
    execute "update sys_processes set name = 'gp_article/docs/publish' where name = 'gp_article/docs/publish_doc'"
  end
end
