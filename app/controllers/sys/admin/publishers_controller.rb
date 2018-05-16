class Sys::Admin::PublishersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(action: :index) if params[:reset]
  end

  def index
    @items = Sys::PublishersFinder.new(Sys::Publisher.in_site(Core.site))
                           .search(params[:criteria])
                           .order(:path)

    if params[:destroy]
      num = @items.count
      @items.find_each(&:destroy)
      return redirect_to url_for(action: :index), notice: '削除処理が完了しました。（#{num}件）'
    end

    @items = @items.paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Sys::Publisher.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end
end
