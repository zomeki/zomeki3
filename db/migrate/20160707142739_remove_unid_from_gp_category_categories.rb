class RemoveUnidFromGpCategoryCategories < ActiveRecord::Migration
  def change
    remove_column :gp_category_categories, :unid, :integer
  end
end
