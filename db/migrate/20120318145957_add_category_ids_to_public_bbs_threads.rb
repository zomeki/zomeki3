class AddCategoryIdsToPublicBbsThreads < ActiveRecord::Migration[4.2]
  def change
    add_column :public_bbs_threads, :category_ids, :text
  end
end
