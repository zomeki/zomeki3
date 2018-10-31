class AddSortNoToGpCategoryCategorizations < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_category_categorizations, :sort_no, :integer
  end
end
