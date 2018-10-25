class AddMoreLayoutIdToOrganizationGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :organization_groups, :more_layout_id, :integer
  end
end
