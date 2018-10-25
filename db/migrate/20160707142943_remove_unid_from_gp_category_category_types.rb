class RemoveUnidFromGpCategoryCategoryTypes < ActiveRecord::Migration[4.2]
  def change
    remove_column :gp_category_category_types, :unid, :integer
  end
end
