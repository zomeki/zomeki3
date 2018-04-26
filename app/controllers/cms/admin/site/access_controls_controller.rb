class Cms::Admin::Site::AccessControlsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    @site = Cms::Site.find(params[:site])
  end

  def index
    @items = @site.access_controls
                  .order(:target_type, :target_location, :id)
                  .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = @site.access_controls.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = @site.access_controls.build(state: 'enabled')
  end

  def create
    @item = @site.access_controls.build(access_control_params)
    _create @item do
      refresh
    end
  end

  def update
    @item = @site.access_controls.find(params[:id])
    @item.attributes = access_control_params
    _update @item do
      refresh
    end
  end

  def destroy
    @item = @site.access_controls.find(params[:id])
    _destroy @item do
      refresh
    end
  end

  def enable
    enable_access_control
    update_configs

    redirect_to url_for(action: :index), notice: 'アクセス制御を有効にしました。'
  end

  def disable
    disable_access_control
    update_configs

    redirect_to url_for(action: :index), notice: 'アクセス制御を無効にしました。'
  end

  private

  def enable_access_control
    @site.load_site_settings
    @site.in_setting_site_access_control_state = 'enabled'
    @site.save
  end

  def disable_access_control
    @site.load_site_settings
    @site.in_setting_site_access_control_state = 'disabled'
    @site.save
  end

  def refresh
    if @site.access_controls.where(state: 'enabled').empty?
      disable_access_control
      flash[:notice] = 'アクセス制御を無効にしました。'
    end

    update_configs
  end

  def update_configs
    Cms::SiteConfigService.new(@site).update
    Cms::FileTransferCallbacks.new(:basic_auth_htpasswd_path).enqueue(@site)
  end

  def access_control_params
    params.require(:item).permit(:state, :target_type, :target_location, :basic_auth, :ip_order, :ip,
                                 :creator_attributes => [:id, :group_id, :user_id])
  end
end
