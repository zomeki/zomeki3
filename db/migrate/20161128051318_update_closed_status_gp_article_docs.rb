class UpdateClosedStatusGpArticleDocs < ActiveRecord::Migration[5.0]
  def change
    GpArticle::Doc.where(state: 'closed').update_all(state: 'finish')
  end
end
