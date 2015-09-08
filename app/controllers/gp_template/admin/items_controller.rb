# encoding: utf-8
class GpTemplate::Admin::ItemsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = GpTemplate::Content::Template.find(params[:content])
    @template = @content.templates.find(params[:template_id])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @template.items.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    @item = @template.items.find(params[:id])
    _show @item
  end

  def new
    @item = @template.items.build
  end

  def create
    @item = @template.items.build(item_params)
    _create @item
  end

  def update
    @item = @template.items.find(params[:id])
    @item.attributes = item_params
    _update @item
  end

  def destroy
    @item = @template.items.find(params[:id])
    _destroy @item
  end

  private

  def item_params
    params.require(:item).permit(:item_options, :item_type, :name, :sort_no, :state, :style_attribute, :title)
  end
end
