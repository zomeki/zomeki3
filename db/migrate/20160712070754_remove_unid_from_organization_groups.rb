class RemoveUnidFromOrganizationGroups < ActiveRecord::Migration[4.2]
  def change
    remove_column :organization_groups, :unid, :integer
  end
end
