class Sys::Admin::Reorg::GroupsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)

    if params[:parent] == '0'
      @parent = nil
    else
      @parent = Sys::Reorg::Group.find(params[:parent])
      return error_auth unless @parent.site_ids.include?(Core.site.id)
    end

    @schedule = Sys::Reorg::Schedule.where(site: Core.site).first
  end

  def index
    roots = Sys::Reorg::Group.in_site(Core.site).roots
    @root = roots.first if roots.size == 1
    return redirect_to url_for(action: :index, parent: @root.id) if @root && params[:parent] == '0'

    @groups = Sys::Reorg::Group.in_site(Core.site)
                               .order(:sort_no, :code, :id)
                               .preload(:source_groups, :destination_groups)
                               .to_tree
    @groups = @groups.flat_map(&:children) if @root

    @users = if @parent
               Sys::Reorg::User.in_group(@parent).order(:account).preload(:source_users, :destination_users)
             else
               []
             end

    _index @groups
  end

  def show
    @item = Sys::Reorg::Group.find(params[:id])
    return error_auth unless @item.readable?

    @organization_groups = Organization::Reorg::Group.in_site(Core.site).where(sys_group_code: @item.code)

    _show @item
  end

  def new
    @item = Sys::Reorg::Group.new(
      state: 'enabled',
      parent_id: @parent.try!(:id),
      ldap: 0,
      web_state: 'public'
    )
  end

  def create
    @item = Sys::Reorg::Group.new(group_params)
    @item.ldap = 0
    @item.level_no = @item.parent.try!(:level_no).to_i + 1
    @item.sites << Core.site if @item.sites.empty?
    _create @item do
      @item.change_state = @item.detect_change_state
      @item.save
      refresh_organization_groups(@item.sites)
    end
  end

  def update
    @item = Sys::Reorg::Group.find(params[:id])
    @item.attributes = group_params
    @item.level_no = @item.parent.try!(:level_no).to_i + 1
    @item.sites << Core.site if @item.sites.empty?
    _update @item do
      @item.change_state = @item.detect_change_state
      @item.save
      update_level_no(@item)
      refresh_organization_groups(@item.sites)
    end
  end

  def destroy
    @item = Sys::Reorg::Group.find(params[:id])
 
    if @item.sys_group.blank?
      _destroy @item do
        disuse_children(@item)
        refresh_organization_groups(@item.sites)
      end
    else
      @item.change_state = 'delete'
      _update @item do
        disuse_children(@item)
        refresh_organization_groups(@item.sites)
      end
    end
  end

  private

  def group_params
    params.require(:item).permit(
      :address, :code, :email, :fax, :ldap, :name, :name_en, :note,
      :parent_id, :sort_no, :state, :tel, :tel_attend, :site_ids => [],
      :group_migrations_attributes => [:id, :source_group_id]
    )
  end

  def refresh_organization_groups(sites)
    sites.each do |site|
      Organization::Reorg::GroupRefreshJob.perform_now(site)
    end
  end

  def update_level_no(item)
    item.descendants.each do |child|
      child.update_columns(level_no: child.ancestors.size)
    end
  end

  def disuse_children(item)
    item.descendants.each do |child|
      if child.sys_group.blank?
        child.destroy
      else
        child.change_state = 'delete'
        child.save
        child.group_migrations.destroy_all
      end
    end
  end
end
