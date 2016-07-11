class RemoveUnidFromFeedFeeds < ActiveRecord::Migration
  def change
    remove_column :feed_feeds, :unid, :integer
  end
end
