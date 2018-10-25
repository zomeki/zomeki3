class RemoveUnidFromCmsFeeds < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_feeds, :unid, :integer
  end
end
