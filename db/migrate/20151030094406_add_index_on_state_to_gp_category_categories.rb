class AddIndexOnStateToGpCategoryCategories < ActiveRecord::Migration[4.2]
  def change
    add_index :gp_category_categories, :state
  end
end
