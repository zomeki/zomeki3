class Sys::ReorgsScript < ParametersScript
  def exec
    @site = ::Script.site

    Rails.application.eager_load!
    @service_klasses = ReorgService.subclasses.sort_by(&:name)

    ::Script.total 1
    ::Script.progress @site do
      ApplicationRecord.transaction do
        reorganize
      end
      Cms::RebuildJob.perform_later(@site, all: true)
    end
  end

  private

  def reorganize
    ::Script.log "processing groups..."

    groups = Sys::Reorg::Group.in_site(@site)
                              .order(:sort_no, :code, :id)
                              .preload(:sys_group, source_groups: :sys_group)
                              .to_tree.flat_map(&:descendants)
    groups.each do |group|
      apply_group(group)
    end

    take_over_groups(groups)

    ::Script.log "processing users..."

    users = Sys::Reorg::User.in_site(@site)
                            .order(:account)
                            .preload(:sys_user, source_users: :sys_user)
    users.each do |user|
      apply_user(user)
    end

    take_over_users(users)

    ::Script.log "processing organization contents..."

    Organization::GroupRefreshJob.perform_now(@site)

    Organization::Content::Group.where(site: @site).each do |content|
      groups = Organization::Reorg::Group.where(content: content)
      groups.each do |group|
        apply_organization_group(group)
      end
    end
  end

  def apply_group(group)
    case group.change_state
    when 'create', 'update'
      sys_group = group.sys_group || Sys::Group.new
      sys_group.attributes = group.attributes.except('id').slice(*sys_group.class.column_names)
      sys_group.parent = group.parent.sys_group if group.parent
      sys_group.site_ids = group.site_belongings.map(&:site_id)
      if sys_group.save
        group.sys_group = sys_group
        group.save
      end
    when 'delete'
      if (sys_group = group.sys_group)
        sys_group.destroy
      end
    end

    ::Script.log "sys_groups: #{group.change_state} #{sys_group.id}" if sys_group
  end

  def make_group_map(groups)
    group_map = {}
    groups.each do |dst|
      next unless dst.sys_group
      dst.source_groups.each do |src|
        next unless src.sys_group
        group_map[src.sys_group] = dst.sys_group
      end
    end
    group_map
  end

  def take_over_groups(groups)
    group_map = make_group_map(groups)

    @service_klasses.each do |service_klass|
      service = service_klass.new
      result = service.reorganize_group(group_map)
      next unless result

      result.each do |(src, dst), ids|
        ::Script.log "#{service.model.table_name}: #{src.id} -> #{dst.id}: #{ids.join(',')}"
      end
    end
  end

  def apply_user(user)
    case user.change_state
    when 'create', 'update'
      sys_user = user.sys_user || Sys::User.new
      sys_user.attributes = user.attributes.except('id').slice(*sys_user.class.column_names)
      sys_user.groups = user.groups.map(&:sys_group)
      sys_user.role_names = user.role_names
      if sys_user.save
        user.sys_user = sys_user
        user.save
      end
    when 'delete'
      if (sys_user = user.sys_user)
        sys_user.destroy
      end
    end

    ::Script.log "sys_users: #{user.change_state} #{sys_user.id}" if sys_user
  end

  def make_user_map(users)
    user_map = {}
    users.each do |dst|
      next unless dst.sys_user
      dst.source_users.each do |src|
        next unless src.sys_user
        user_map[src.sys_user] = dst.sys_user
      end
    end
    user_map
  end

  def take_over_users(users)
    user_map = make_user_map(users)

    @service_klasses.each do |service_klass|
      service = service_klass.new
      result = service.reorganize_user(user_map)
      next unless result

      result.each do |(src, dst), ids|
        ::Script.log "#{service.model.table_name}: #{src.id} -> #{dst.id}: #{ids.join(',')}"
      end
    end
  end

  def apply_organization_group(group)
    case group.change_state
    when 'create', 'update'
      if (org_group = group.org_group)
        org_group.update_columns(group.attributes.except('id').slice(*org_group.class.column_names))
      end
    end
  end
end
