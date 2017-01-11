class AdBanner::Admin::BannersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = AdBanner::Content::Banner.find_by(id: params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    items = @content.banners.except(:order).order(created_at: :desc)

    items = if params[:published].present?
              items.published
            elsif params[:closed].present?
              items.closed
            else
              items
            end

    @items = items.paginate(page: params[:page], per_page: 50)

    _index @items
  end

  def show
    @item = @content.banners.find(params[:id])
    _show @item
  end

  def new
    @item = @content.banners.build(site_id: Core.site.id)
  end

  def create
    @item = @content.banners.build(banner_params)
    @item.site_id = Core.site.id
    _create @item
  end

  def update
    @item = @content.banners.find(params[:id])
    @item.attributes = banner_params
    @item.skip_upload if @item.file.blank? && @item.file_exist?
    _update @item
  end

  def destroy
    @item = @content.banners.find(params[:id])
    _destroy @item
  end

  def file_content
    item = @content.banners.find(params[:id])
    send_file item.upload_path, filename: item.name
  end

  private

  def banner_params
    params.require(:item).permit(
      :advertiser_contact, :advertiser_email, :advertiser_name, :advertiser_phone,
      :closed_at, :file, :group_id, :name, :published_at, :sort_no, :state, :title, :url, :target,
      :creator_attributes => [:id, :group_id, :user_id]
    )
  end
end
