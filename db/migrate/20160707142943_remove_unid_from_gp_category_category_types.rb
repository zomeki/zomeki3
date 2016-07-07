class RemoveUnidFromGpCategoryCategoryTypes < ActiveRecord::Migration
  def change
    remove_column :gp_category_category_types, :unid, :integer
  end
end
