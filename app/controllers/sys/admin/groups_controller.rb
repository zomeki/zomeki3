class Sys::Admin::GroupsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)

    if params[:parent] == '0'
      @parent = nil
    else
      @parent = Sys::Group.find(params[:parent])
      return error_auth unless @parent.site_ids.include?(Core.site.id)
    end
  end

  def index
    if @parent
      @groups = Core.site.groups.order(:sort_no, :code, :id).to_tree.flat_map(&:children)
      @users = Core.site.users.in_group(@parent).order(:account)
    else
      @groups = Core.site.groups.order(:sort_no, :code, :id).to_tree
      return redirect_to url_for(action: :index, parent: @groups.first.id) if @groups.size == 1
      @users = []
    end

    _index @groups
  end

  def show
    @item = Sys::Group.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Sys::Group.new(
      state: 'enabled',
      parent_id: @parent.try!(:id),
      ldap: 0,
      web_state: 'public'
    )
  end

  def create
    @item = Sys::Group.new(group_params)
    @item.ldap = 0
    @item.level_no = @item.parent.try!(:level_no).to_i + 1
    @item.sites << Core.site if @item.sites.empty?
    _create @item do
      refresh_organization_groups(@item.sites)
    end
  end

  def update
    @item = Sys::Group.find(params[:id])
    @item.attributes = group_params
    @item.level_no = @item.parent.try!(:level_no).to_i + 1
    @item.sites << Core.site if @item.sites.empty?
    _update @item do
      update_level_no
      refresh_organization_groups(@item.sites)
    end
  end

  def destroy
    @item = Sys::Group.find(params[:id])

    unless @item.deletable_group?
      flash[:notice] = [
        "グループの削除に失敗しました。以下のいずれかの条件に該当しないか確認してください。",
        "・下位に有効なグループが存在している",
        "・グループ内または下位のグループ内にユーザーが存在している",
        "・グループまたは下位グループの作成した記事が存在している",
      ].join('<br />')
      return redirect_to action: :show
    end

    sites = @item.sites.to_a

    _destroy @item do
      refresh_organization_groups(sites)
    end
  end

  private

  def group_params
    params.require(:item).permit(
      :address, :code, :email, :fax, :ldap, :name, :name_en, :note,
      :parent_id, :sort_no, :state, :tel, :tel_attend, :site_ids => []
    )
  end

  def update_level_no
    @item.descendants.each do |child|
      child.update_columns(level_no: child.ancestors.size)
    end
  end

  def refresh_organization_groups(sites)
    sites.each do |site|
      Organization::GroupRefreshJob.perform_now(site)
    end
  end
end
