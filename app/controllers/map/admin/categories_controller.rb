class Map::Admin::CategoriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_action :get_item_and_setting, only: [:edit, :update]

  def pre_dispatch
    @content = Map::Content::Marker.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)

    @category_type = @content.category_types.find(params[:category_type_id])
    @parent_category = @category_type.categories.find_by(id: params[:category_id])
  end

  def index
    @items = if @parent_category
               @parent_category.children.paginate(page: params[:page], per_page: 50)
             else
               @category_type.categories.where(id: @content.categories.pluck(:id)).paginate(page: params[:page], per_page: 50)
             end
  end

  def edit
  end

  def update
    @icon.attributes = icon_params
    _update @icon
  end

  private

  def get_item_and_setting
    @item = @category_type.categories.find(params[:id])
    @icon = @content.marker_icons.where(relatable: @item).first_or_initialize
  end

  def icon_params
    params.require(:item).permit(:url)
  end
end
