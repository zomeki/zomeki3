class AddDocsOrderToGpCategoryCategoryTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_category_category_types, :docs_order, :string
  end
end
