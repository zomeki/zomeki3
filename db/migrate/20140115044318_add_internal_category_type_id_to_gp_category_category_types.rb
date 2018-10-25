class AddInternalCategoryTypeIdToGpCategoryCategoryTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_category_category_types, :internal_category_type_id, :integer
  end
end
