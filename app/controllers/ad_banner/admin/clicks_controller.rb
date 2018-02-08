class AdBanner::Admin::ClicksController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = AdBanner::Content::Banner.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to url_for(action: :index) if params[:reset]

    @banner = @content.banners.find(params[:banner_id])
  end

  def index
    @items = AdBanner::ClicksFinder.new(@banner.clicks)
                                   .search(params[:criteria])
                                   .paginate(page: params[:page], per_page: 50)

    _index @items
  end
end
