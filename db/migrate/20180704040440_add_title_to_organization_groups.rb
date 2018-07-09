class AddTitleToOrganizationGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :organization_groups, :title, :string
  end
end
