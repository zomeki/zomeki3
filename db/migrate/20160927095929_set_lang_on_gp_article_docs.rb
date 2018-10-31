class SetLangOnGpArticleDocs < ActiveRecord::Migration[4.2]
  def up
    execute "update gp_article_docs set lang = 'ja'"
  end
end
