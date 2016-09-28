class SetLangOnGpArticleDocs < ActiveRecord::Migration
  def up
    execute "update gp_article_docs set lang = 'ja'"
  end
end
