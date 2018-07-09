class Sys::Admin::GroupUsersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(action: :index) if params[:reset]
    
    id      = params[:parent] == '0' ? 1 : params[:parent]
    @parent = Sys::Group.find(id)
  end
  
  def index
    if params[:options]
      render 'index_options', layout: false
    else
      redirect_to url_for(controller: :groups, parent: @parent)
    end
  end
  
  def show
    @item = Sys::User.find(params[:id])
    return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Sys::User.new(
      state: 'enabled',
      ldap: 0,
      auth_no: 2
    )
    @item.users_groups.build(group_id: @parent.id)
  end
  
  def create
    @item = Sys::User.new(user_params)
    @item.ldap = 0
    _create(@item, location: url_for(controller: :groups, parent: @parent))
  end
  
  def update
    @item = Sys::User.find(params[:id])
    @item.attributes = user_params
    _update(@item, location: url_for(controller: :groups, parent: @parent))
  end
  
  def destroy
    @item = Sys::User.find(params[:id])
    _destroy(@item, location: url_for(controller: :groups, parent: @parent))
  end

  private

  def user_params
    params.require(:item).permit(
      :account, :admin_creatable, :auth_no, :email, :ldap, :name, :name_en, :password, :state,
      :role_name_ids => [],
      :users_groups_attributes => [:id, :group_id]
    )
  end
end
