class AddDocsOrderToGpCategoryCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_category_categories, :docs_order, :string
  end
end
