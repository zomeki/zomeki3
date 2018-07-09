class UpdateTitleOnOrganizationGroups < ActiveRecord::Migration[5.0]
  def up
    Organization::Group.find_each do |group|
      group.update_columns(title: group.sys_group.name) if group.sys_group
    end
  end

  def down
  end
end
