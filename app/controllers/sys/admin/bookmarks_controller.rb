class Sys::Admin::BookmarksController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @bookmarks = Sys::Bookmark.roots.where(user_id: Core.user.id).order(:sort_no, :id)

    if params[:parent] != '0'
      @parent = Sys::Bookmark.find(params[:parent])
    end
  end

  def index
    @items = Sys::Bookmark.where(user_id: Core.user.id)
                          .where(parent_id: @parent ? @parent.id : nil)
                          .order(:sort_no, :id)
                          .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Sys::Bookmark.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Sys::Bookmark.new(url: params[:url])
    @item.parent_id = @parent.id if @parent
  end

  def create
    @item = Sys::Bookmark.new(bookmark_params)
    @item.user_id = Core.user.id
    @item.level_no = @item.parent ? @item.parent.level_no + 1 : 1
    _create @item
  end

  def update
    @item = Sys::Bookmark.find(params[:id])
    @item.attributes = bookmark_params
    @item.level_no = @item.parent ? @item.parent.level_no + 1 : 1
    _update @item do
      update_level_no
    end
  end

  def destroy
    @item = Sys::Bookmark.find(params[:id])
    _destroy @item
  end

  private

  def bookmark_params
    params.require(:item).permit(:parent_id, :title, :url, :sort_no)
  end

  def update_level_no
    @item.descendants.each do |child|
      child.update_columns(level_no: child.ancestors.size)
    end
  end
end
