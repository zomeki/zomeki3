class Feed::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Feed::Content::Feed.find(params[:content])
    return error_auth unless @content.editable?
  end

  def index
    @items = Feed::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = Feed::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def new
    error_auth
  end

  def create
    error_auth
  end

  def update
    @item = Feed::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]
    _update(@item)
  end

  def destroy
    error_auth
  end

end
