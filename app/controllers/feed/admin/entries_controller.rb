class Feed::Admin::EntriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Feed::Content::Feed.find_by(id: params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return error_auth unless @feed = @content.feeds.find(params[:feed_id])
  end

  def index
    return update_entries if params[:do] == "update_entries"
    return delete_entries if params[:do] == "delete_entries"
    
    item = Feed::FeedEntry.new
    item.and :feed_id, @feed.id
    item.page  params[:page], params[:limit]
    item.order params[:sort],  entry_updated: :desc, id: :desc
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Feed::FeedEntry.new.find(params[:id])
    _show @item
  end

  def new
    return error_auth
  end

  def create
    return error_auth
  end

  def update
    @item = Feed::FeedEntry.new.find(params[:id])
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
