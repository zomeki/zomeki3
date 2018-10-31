class AddTemplateIdToGpCategoryCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_category_categories, :template_id, :integer
  end
end
