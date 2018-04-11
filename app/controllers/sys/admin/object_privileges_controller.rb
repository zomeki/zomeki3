class Sys::Admin::ObjectPrivilegesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    @parent = Sys::RoleName.find(params[:parent])
    return error_auth unless @parent.site_id == Core.site.id
  end
  
  def index
    @items = Sys::ObjectPrivilege.joins(:concept)
                                 .where(id: Sys::ObjectPrivilege.select('MIN(id) as id').where(role_id: @parent.id).group(:concept_id))
                                 .order(Cms::Concept.arel_table[:name].asc)
                                 .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end
  
  def show
    @item = Sys::ObjectPrivilege.find(params[:id])
    #return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Sys::ObjectPrivilege.new(
      role_id: @parent.id
    )
  end

  def create
    @item = Sys::ObjectPrivilege.new(privilege_params)
    @item.role_id = @parent.id
    @item.in_actions = {} unless privilege_params[:in_actions]
    _create @item
  end

  def update
    @item = Sys::ObjectPrivilege.find(params[:id])
    @item.attributes = privilege_params
    @item.in_actions = {} unless privilege_params[:in_actions]
    _update @item
  end

  def destroy
    @item = Sys::ObjectPrivilege.find(params[:id])
    _destroy @item
  end

  private

  def privilege_params
    params.require(:item).permit(:concept_id, in_actions: [])
  end
end
