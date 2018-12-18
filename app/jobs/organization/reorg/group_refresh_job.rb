class Organization::Reorg::GroupRefreshJob < ApplicationJob
  def perform(site)
    @site = site

    Organization::Content::Group.where(site: @site).each do |content|
      refresh_groups(content)
    end
  end

  private

  def refresh_groups(content)
    sys_group_map = Sys::Reorg::Group.in_site(@site).to_tree.flat_map(&:descendants).reject(&:root?).index_by(&:code)
    group_map = Organization::Reorg::Group.where(content: content).index_by(&:sys_group_code)

    sys_group_map.each do |code, sys_group|
      group = group_map[code] || Organization::Reorg::Group.new(content: content, sys_group_code: code)
      group.name = sys_group.name_en
      group.title = sys_group.name

      if group.has_changes_to_save?
        group.change_state = group.detect_change_state
        group.save
      end
    end

    group_map.each do |code, group|
      group.destroy unless sys_group_map[code]
    end
  end
end
