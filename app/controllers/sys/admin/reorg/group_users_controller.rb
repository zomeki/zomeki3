class Sys::Admin::Reorg::GroupUsersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)

    id      = params[:parent] == '0' ? 1 : params[:parent]
    @parent = Sys::Reorg::Group.find(id)
  end
  
  def index
    redirect_to url_for(controller: :groups, parent: @parent)
  end
  
  def show
    @item = Sys::Reorg::User.find(params[:id])
    return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Sys::Reorg::User.new(
      state: 'enabled',
      ldap: 0,
      auth_no: 2
    )
    @item.users_groups.build(group_id: @parent.id)
  end
  
  def create
    @item = Sys::Reorg::User.new(user_params)
    @item.ldap = 0
    _create(@item, location: url_for(controller: :groups, parent: @parent)) do
      @item.change_state = @item.detect_change_state
      @item.save
    end
  end
  
  def update
    @item = Sys::Reorg::User.find(params[:id])
    @item.attributes = user_params
    _update(@item, location: url_for(controller: :groups, parent: @parent)) do
      @item.change_state = @item.detect_change_state
      @item.save
    end
  end
  
  def destroy
    @item = Sys::Reorg::User.find(params[:id])

    if @item.sys_user.blank?
      _destroy(@item, location: url_for(controller: :groups, parent: @parent))
    else
      @item.change_state = 'delete'
      _update(@item, location: url_for(controller: :groups, parent: @parent))
    end
  end

  private

  def user_params
    params.require(:item).permit(
      :account, :admin_creatable, :auth_no, :email, :ldap, :name, :name_en, :password, :state,
      :role_name_ids => [],
      :users_groups_attributes => [:id, :group_id],
      :user_migrations_attributes => [:id, :source_user_id]
    )
  end
end
