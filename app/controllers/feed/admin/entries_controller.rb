class Feed::Admin::EntriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Feed::Content::Feed.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @feed = @content.feeds.find(params[:feed_id])
  end

  def index
    return update_entries if params[:do] == "update_entries"
    return delete_entries if params[:do] == "delete_entries"
    
    @items = Feed::FeedEntry.where(feed_id: @feed.id).order(entry_updated: :desc, id: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Feed::FeedEntry.find(params[:id])
    _show @item
  end

  def new
    return error_auth
  end

  def create
    return error_auth
  end

  def update
    @item = Feed::FeedEntry.find(params[:id])
    @item.attributes = entry_params
    _update @item
  end

  def destroy
    return error_auth
  end

protected

  def entry_params
    params.require(:item).permit(:state)
  end

  def update_entries
    if @feed.update_feed(:destroy => true)
      flash[:notice] = "エントリを更新しました。"
    else
      flash[:notice] = "エントリの更新に失敗しました。"
    end
    redirect_to feed_feed_entries_path
  end

  def delete_entries
    if @feed.entries.destroy_all
      flash[:notice] = "エントリを削除しました。"
    else
      flash[:notice] = "エントリの削除に失敗しました。"
    end
    redirect_to feed_feed_entries_path
  end
end
