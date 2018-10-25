class AddOutlineToOrganizationGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :organization_groups, :outline, :text
  end
end
