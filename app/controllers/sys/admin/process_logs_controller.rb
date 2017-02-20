class Sys::Admin::ProcessLogsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(action: :index) if params[:reset]
  end

  def index
    @items = Sys::Process.where(site_id: Core.site.id).search_with_params(params)
                         .order(id: :desc)
                         .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Sys::Process.find(params[:id])
    _show @item
  end
end
