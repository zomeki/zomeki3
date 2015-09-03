# encoding: utf-8
class Sys::Admin::RoleNamesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end
  
  def index
    @items = Sys::RoleName.where(site_id: Core.site.id).search_with_params(params).order(:name)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end
  
  def show
    @item = Sys::RoleName.find(params[:id])
    #return error_auth unless @item.readable?
    return error_auth unless @item.site_id == Core.site.id
    _show @item
  end

  def new
    @item = Sys::RoleName.new
  end
  
  def create
    @item = Sys::RoleName.new(role_params)
    @item.site_id = Core.site.id
    _create @item
  end
  
  def update
    @item = Sys::RoleName.find(params[:id])
    return error_auth unless @item.site_id == Core.site.id
    @item.attributes = role_params
    _update @item
  end
  
  def destroy
    @item = Sys::RoleName.find(params[:id])
    return error_auth unless @item.site_id == Core.site.id
    _destroy @item
  end

  private

  def role_params
    params.require(:item).permit(:name, :title)
  end
end
