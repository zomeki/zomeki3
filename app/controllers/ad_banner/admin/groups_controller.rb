# encoding: utf-8
class AdBanner::Admin::GroupsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = AdBanner::Content::Banner.find_by(id: params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @content.groups.paginate(page: params[:page], per_page: 50)
    _index @items
  end

  def show
    @item = @content.groups.find(params[:id])
    _show @item
  end

  def new
    @item = @content.groups.build
  end

  def create
    @item = @content.groups.build(group_params)
    _create @item
  end

  def update
    @item = @content.groups.find(params[:id])
    @item.attributes = group_params
    _update @item
  end

  def destroy
    @item = @content.groups.find(params[:id])
    _destroy @item
  end

  private

  def group_params
    params.require(:item).permit(:name, :sort_no, :title, :in_creator => [:group_id, :user_id])
  end
end
