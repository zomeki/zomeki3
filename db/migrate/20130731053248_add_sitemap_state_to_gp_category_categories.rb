class AddSitemapStateToGpCategoryCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_category_categories, :sitemap_state, :string
  end
end
