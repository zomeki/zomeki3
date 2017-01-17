class SetCmsSiteBelongingsForRootGroup < ActiveRecord::Migration[5.0]
  def up
    root_group = Sys::Group.root
    Cms::Site.find_each do |site|
      unless site.groups.where(parent_id: 0).exists?
        site.site_belongings.create(group_id: root_group.id)
      end
    end
  end

  def down
  end
end
