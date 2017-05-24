class Cms::Admin::Site::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(action: :index) if params[:reset]
    @site = Cms::Site.find(params[:site])
    @site.load_site_settings
  end

  def index
    @items = Cms::SiteSetting.configs.values.select { |config| config[:index] }
                             .map { |config| @site.settings.where(name: config[:id]).first_or_initialize }
    _index @items
  end

  def show
    @item = Cms::SiteSetting.where(site_id: @site.id, name: params[:id]).first_or_initialize
    _show @item
  end

  def update
    @item = Cms::SiteSetting.where(site_id: @site.id, name: params[:id]).first_or_initialize
    @site.attributes = site_setting_params
    _update @site
  end

  private

  def site_setting_params
    params.require(:item).permit( *Cms::Model::Rel::SiteSetting::IN_SETTING_NAMES )
  end
end
