class AddIncludeCcAndLogicToMailinFilters < ActiveRecord::Migration[5.0]
  def change
    add_column :mailin_filters, :include_cc, :boolean
    add_column :mailin_filters, :logic, :string
  end
end
