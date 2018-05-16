require 'yaml/store'
class Cms::Admin::SitesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
    @items = Cms::Site.order(:id)
    # システム管理者以外は所属サイトしか操作できない
    @items = @items.where(id: current_user.site_ids) unless current_user.root?
    @items = @items.paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Cms::Site.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::Site.new(state: 'public')
    return error_auth unless @item.creatable?
  end

  def create
    @item = Cms::Site.new(site_params)
    @item.portal_group_state = 'visible'
    _create(@item, notice: "登録処理が完了しました。 （反映にはWebサーバーの再起動が必要です。）") do
      update_configs
    end
  end

  def update
    @item = Cms::Site.find(params[:id])
    @item.attributes = site_params
    _update @item do
      update_configs
      unless @item.smart_phone_publication?
        Sys::Publisher.in_site(@item.id).with_smartphone_dependent.find_each(&:destroy)
      end
    end
  end

  def destroy
    @item = Cms::Site.find(params[:id])
    _destroy(@item) do
      cookies.delete(:cms_site)
      update_configs
    end
  end

  protected

  def update_configs
    Cms::SiteConfigService.new(@item).update
  end

  private

  def site_params
    params.require(:item).permit(
      :name, :state, :body, :full_uri, :mobile_full_uri, :admin_full_uri,
      :og_description, :og_image, :og_title, :og_type,
      :smart_phone_layout, :smart_phone_publication, :spp_target, :mobile_feature,
      :google_map_api_key,
      :in_root_group_id,
      :creator_attributes => [:id, :group_id, :user_id]
    )
  end
end
