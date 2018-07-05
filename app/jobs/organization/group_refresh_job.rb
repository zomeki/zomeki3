class Organization::GroupRefreshJob < ApplicationJob
  def perform(site)
    @site = site

    Organization::Content::Group.where(site: @site).each do |content|
      refresh_groups(content)
    end
  end

  private

  def refresh_groups(content)
    sys_group_map = @site.groups.to_tree.flat_map(&:descendants).reject(&:root?).index_by(&:code)
    group_map = content.groups.index_by(&:sys_group_code)

    sys_group_map.each do |code, sys_group|
      group = group_map[code] || content.groups.build(sys_group_code: code)
      group.name = sys_group.name_en
      group.title = sys_group.name
      group.save if group.changed?
    end

    group_map.each do |code, group|
      group.destroy unless sys_group_map[code]
    end
  end
end
