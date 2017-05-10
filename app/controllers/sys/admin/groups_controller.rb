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
      @groups = Core.site.groups.in_group(@parent).order(:sort_no, :code, :id)
      @users = Core.site.users.in_group(@parent).order(:account)
    else
      @groups = Core.site.groups.where(parent_id: 0).order(:sort_no, :code, :id)
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
      :state      => 'enabled',
      :parent_id  => @parent.try!(:id),
      :ldap       => 0,
      :web_state  => 'public'
    )
  end

  def create
    @item = Sys::Group.new(group_params)
    @item.ldap = 0
    @item.level_no = @item.parent.try!(:level_no).to_i + 1
    @item.sites << Core.site if @item.sites.empty?
    _create @item do
      Organization::GroupRefreshJob.perform_now(@item.sites)
    end
  end

  def update
    @item = Sys::Group.find(params[:id])
    @item.attributes = group_params
    @item.level_no = @item.parent.try!(:level_no).to_i + 1
    @item.sites << Core.site if @item.sites.empty?
    _update @item do
      Organization::GroupRefreshJob.perform_now(@item.sites)
    end
  end

  def destroy
    @item = Sys::Group.find(params[:id])
    _destroy @item do
      Organization::GroupRefreshJob.perform_now(@item.sites)
    end
  end

  private

  def group_params
    params.require(:item).permit(
      :address, :code, :email, :fax, :ldap, :name, :name_en, :note,
      :parent_id, :sort_no, :state, :tel, :tel_attend, :site_ids => []
    )
  end
end
