class Sys::Admin::UsersSessionsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.root?
    return redirect_to(action: :index) if params[:reset]
  end

  def index
    @items = Sys::UsersSession.date_after(:updated_at, Sys::UsersSession.expire_after.ago)
                              .order(updated_at: :desc)
                              .paginate(page: params[:page], per_page: params[:limit])
                              .preload(:user)

    _index @items
  end

  def show
    @item = Sys::UsersSession.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def destroy
    @item = Sys::UsersSession.find(params[:id])
    return error_auth unless @item.deletable?
    _destroy @item
  end
end
