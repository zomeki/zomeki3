class Organization::GroupRefreshJob < ApplicationJob
  def perform(site_ids)
    Organization::Content::Group.where(site_id: site_ids).each do |content|
      refresh_groups(content)
    end
  end

  private

  def refresh_groups(content)
    sys_groups = content.top_layer_sys_groups.flat_map { |g| g.descendants_in_site(content.site) }
    sys_groups.each do |sys_group|
      group = content.groups.where(sys_group_code: sys_group.code).first_or_initialize
      group.name = sys_group.name_en
      unless group.valid?
        group.name = "#{sys_group.name_en}_#{sys_group.code}"
      end
      group.save
    end

    content.groups.each do |group|
      sys_group = group.sys_group
      group.destroy if sys_group.nil? || !sys_group.sites.include?(content.site)
    end
  end
end
