class AddCategoryIdsToPublicBbsResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :public_bbs_responses, :category_ids, :text
  end
end
