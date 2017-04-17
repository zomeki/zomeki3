class Cms::Admin::Site::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(action: :index) if params[:reset]
    @site = Cms::Site.find(params[:site])
    @site.load_site_settings
  end

  def index
    @items = Cms::SiteSetting::SITE_CONFIGS
    _index @items
  end

  def show
    @item = Cms::SiteSetting.where(name: params[:id], site_id: @site.id).first_or_initialize
    _show @item
  end

  def new
    error_auth
  end

  def create
    error_auth
  end

  def update
    @item = Cms::SiteSetting.where(name: params[:id], site_id: @site.id).first_or_initialize
    @site.attributes = site_setting_params
    _update(@site)
  end

  def destroy
    error_auth
  end

  def site_setting_params
    params.require(:item).permit(
      :in_setting_site_admin_mail_sender,
      :in_setting_site_file_upload_max_size, :in_setting_site_extension_upload_max_size,
      :in_setting_site_common_ssl,
      :in_setting_site_allowed_attachment_type,
      :in_setting_site_link_check,
      :in_setting_site_kana_talk,
      :in_setting_site_map_Coordinate
    )
  end
end
