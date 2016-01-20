# encoding: utf-8
class GpCategory::Admin::CategoryTypesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find(params[:content])
  end

  def index
    if params[:check_boxes]
      @items = @content.category_types
      render 'index_check_boxes', :layout => false
    elsif params[:options]
      @items = @content.category_types
      render 'index_options', :layout => false
    else
      @items = @content.category_types.paginate(page: params[:page], per_page: 50)
      _index @items
    end
  end

  def show
    @item = GpCategory::CategoryType.find(params[:id])
    _show @item
  end

  def new
    @item = GpCategory::CategoryType.new(state: 'public', sort_no: 10)
  end

  def create
    @item = GpCategory::CategoryType.new(category_type_params)
    @item.concept = @content.concept
    @item.content = @content
    @item.in_creator = {'group_id' => Core.user_group.id, 'user_id' => Core.user.id}
    _create @item
  end

  def edit
    @item = GpCategory::CategoryType.find(params[:id])
  end

  def update
    @item = GpCategory::CategoryType.find(params[:id])
    @item.attributes = category_type_params
    _update @item
  end

  def destroy
    @item = GpCategory::CategoryType.find(params[:id])
    _destroy @item
  end

  private

  def category_type_params
    params.require(:item).permit(:concept_id, :docs_order, :internal_category_type_id, :layout_id, :name,
      :sitemap_state, :sort_no, :state, :template_id, :title, :description, :in_creator => [:group_id, :user_id])
  end
end
