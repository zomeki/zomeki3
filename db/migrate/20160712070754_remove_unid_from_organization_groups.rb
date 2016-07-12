class RemoveUnidFromOrganizationGroups < ActiveRecord::Migration
  def change
    remove_column :organization_groups, :unid, :integer
  end
end
