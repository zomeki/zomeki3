class Sys::Reorg::CopyJob < ApplicationJob
  def perform(site)
    @site = site

    ApplicationRecord.transaction do
      sys_groups = Sys::Group.in_site(@site).order(:sort_no, :code, :id).to_tree
      sys_groups.each do |sys_group|
        copy_sys_group(sys_group)
      end

      Organization::Content::Group.where(site: @site).each do |content|
        copy_org_groups(content)
      end
    end
  end

  private

  def copy_sys_group(sys_group, parent = nil)
    group = Sys::Reorg::Group.new
    group.attributes = sys_group.attributes.except('id')
    group.parent = parent
    group.sys_group = sys_group
    group.site_belongings.build(site: @site)
    group.save!

    sys_group.users.order(:account).each do |sys_user|
      user = Sys::Reorg::User.new
      user.attributes = sys_user.attributes.except('id')
      user.sys_user = sys_user
      sys_user.users_groups.each do |sug|
        ug = user.users_groups.build
        ug.attributes = sug.attributes.except('id')
        ug.group = group
      end
      sys_user.users_roles.each do |sur|
        ur = user.users_roles.build
        ur.attributes = sur.attributes.except('id')
      end
      user.save!
    end

    sys_group.children.each do |sys_child|
      copy_sys_group(sys_child, group)
    end
  end

  def copy_org_groups(content)
    org_groups = Organization::Group.where(content: content)
    org_groups.each do |org_group|
      group = Organization::Reorg::Group.new
      group.attributes = org_group.attributes.except('id')
      group.save!
    end
  end
end
