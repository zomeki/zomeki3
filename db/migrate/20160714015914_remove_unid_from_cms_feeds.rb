class RemoveUnidFromCmsFeeds < ActiveRecord::Migration
  def change
    remove_column :cms_feeds, :unid, :integer
  end
end
