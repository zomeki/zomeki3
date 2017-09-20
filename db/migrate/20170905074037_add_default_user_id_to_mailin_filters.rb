class AddDefaultUserIdToMailinFilters < ActiveRecord::Migration[5.0]
  def change
    add_column :mailin_filters, :default_user_id, :integer
  end
end
