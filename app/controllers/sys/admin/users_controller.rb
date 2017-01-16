class Sys::Admin::UsersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(action: :index) if params[:reset]
  end

  def index
    @items = Core.site.users.search_with_params(params).order("LPAD(account, 15, '0')")
                            .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Sys::User.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Sys::User.new(
      :state       => 'enabled',
      :ldap        => 0,
      :auth_no     => 2
    )
  end

  def create
    @item = Sys::User.new(user_params)
    @item.ldap = 0
    _create(@item)
  end

  def update
    @item = Sys::User.find(params[:id])
    return error_auth if !Core.user.root? && @item.root?
    @item.attributes = user_params
    _update(@item)
  end

  def destroy
    @item = Sys::User.find(params[:id])
    return error_auth if !Core.user.root? && @item.root?
    _destroy(@item)
  end

  private

  def user_params
    params.require(:item).permit(
      :admin_creatable, :site_creatable, :in_group_id,
      :account, :name, :name_en, :email, :state, :auth_no, :ldap, :password, :role_name_ids => []
    )
  end
end
