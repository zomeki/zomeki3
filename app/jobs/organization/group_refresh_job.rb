class Organization::GroupRefreshJob < ApplicationJob
  def perform(site)
    @site = site

    Organization::Content::Group.where(site: @site).each do |content|
      refresh_groups(content)
    end
  end

  private

  def refresh_groups(content)
    sys_groups = @site.groups.to_tree.flat_map(&:descendants).reject(&:root?)
    sys_groups.each do |sys_group|
      group = content.groups.where(sys_group_code: sys_group.code).first_or_initialize
      group.name = sys_group.name_en
      group.title = sys_group.name
      group.save
    end

    content.groups.each do |group|
      group.destroy unless sys_groups.detect { |sg| sg.code == group.sys_group_code }
    end
  end
end
