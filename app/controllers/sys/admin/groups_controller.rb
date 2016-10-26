class Sys::Admin::GroupsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)

    id = params[:parent] == '0' ? 1 : params[:parent]

    @parent = Sys::Group.find(id)
    return error_auth unless @parent.id == 1 || @parent.site_ids.include?(Core.site.id)

    @groups = Core.site.groups.in_group(@parent).order(:sort_no, :code, :id).all
    @users = Core.site.users.in_group(@parent).order(:account).all
  end

  def index
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
      :parent_id  => @parent.id,
      :ldap       => 0,
      :web_state  => 'public'
    )
  end

  def create
    @item = Sys::Group.new(group_params)
    @item.parent_id = @parent.id
    parent = Sys::Group.find_by(id: @item.parent_id)
    @item.level_no = parent ? parent.level_no + 1 : 1
    _create(@item) do
      @item.sites << Core.site if @item.sites.empty?
    end
  end

  def update
    @item = Sys::Group.find(params[:id])
    @item.attributes = group_params
    parent = Sys::Group.find_by(id: @item.parent_id)
    @item.level_no = parent ? parent.level_no + 1 : 1
    _update(@item) do
      @item.sites << Core.site if @item.sites.empty?
    end
  end

  def destroy
    @item = Sys::Group.find(params[:id])
    _destroy @item
  end

  private

  def group_params
    params.require(:item).permit(
      :address, :code, :email, :fax, :ldap, :name, :name_en, :note,
      :parent_id, :sort_no, :state, :tel, :tel_attend, :site_ids => []
    )
  end
end
