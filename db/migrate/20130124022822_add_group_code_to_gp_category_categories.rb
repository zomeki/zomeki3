class AddGroupCodeToGpCategoryCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_category_categories, :group_code, :string
  end
end
