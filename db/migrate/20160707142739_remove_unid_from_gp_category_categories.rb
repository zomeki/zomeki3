class RemoveUnidFromGpCategoryCategories < ActiveRecord::Migration[4.2]
  def change
    remove_column :gp_category_categories, :unid, :integer
  end
end
