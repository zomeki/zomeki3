class RemoveUnidFromFeedFeeds < ActiveRecord::Migration[4.2]
  def change
    remove_column :feed_feeds, :unid, :integer
  end
end
