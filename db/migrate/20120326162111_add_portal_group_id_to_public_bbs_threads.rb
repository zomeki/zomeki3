class AddPortalGroupIdToPublicBbsThreads < ActiveRecord::Migration[4.2]
  def change
    add_column :public_bbs_threads, :portal_group_id, :integer
  end
end
