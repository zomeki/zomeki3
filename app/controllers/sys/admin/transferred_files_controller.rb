class Sys::Admin::TransferredFilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    @site = Core.site
    @destination_uri = @site.setting_transfer_dest_domain
  end

  def index
    @items = @site.transferred_files.search_with_params(params).order(version: :desc, id: :asc)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = @site.transferred_files.find(params[:id])
    _show @item
  end

  def new
    return error_auth
  end

  def create
    return error_auth
  end

  def update
    return error_auth
  end

  def destroy
    return error_auth
  end
end
