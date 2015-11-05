class AddIndexOnStateToGpCategoryCategories < ActiveRecord::Migration
  def change
    add_index :gp_category_categories, :state
  end
end
