class AddPortalAreaIdsToPublicBbsThreads < ActiveRecord::Migration[4.2]
  def change
    add_column :public_bbs_threads, :portal_area_ids, :text
  end
end
