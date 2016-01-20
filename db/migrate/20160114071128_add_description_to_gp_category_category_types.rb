class AddDescriptionToGpCategoryCategoryTypes < ActiveRecord::Migration
  def change
    add_column :gp_category_category_types, :description, :string, :limit=>255
  end
end
