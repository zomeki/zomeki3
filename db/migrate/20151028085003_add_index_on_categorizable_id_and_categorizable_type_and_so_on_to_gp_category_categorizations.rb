class AddIndexOnCategorizableIdAndCategorizableTypeAndSoOnToGpCategoryCategorizations < ActiveRecord::Migration
  def change
    add_index :gp_category_categorizations, [:categorizable_id, :categorizable_type], name: 'index_gp_category_categorizations_on_categorizable_id_and_type'
    add_index :gp_category_categorizations, :category_id
    add_index :gp_category_categorizations, :categorized_as
  end
end
