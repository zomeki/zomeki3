class Gnav::Admin::MenuItemsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Gnav::Content::MenuItem.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)

    if (gccct = @content.gp_category_content_category_type)
      @category_types = gccct.category_types
      @category_types_for_option = gccct.category_types_for_option
    else
      redirect_to gnav_content_settings_path, alert: 'カテゴリ種別を設定してください。'
    end
  end

  def index
    @items = @content.menu_items.paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = @content.menu_items.find(params[:id])
    _show @item
  end

  def new
    @item = @content.menu_items.build(state: 'public', sort_no: 10)
  end

  def create
    @item = @content.menu_items.build(menu_item_params)
    _create @item
  end

  def update
    @item = @content.menu_items.find(params[:id])
    @item.attributes = menu_item_params
    _update @item
  end

  def destroy
    @item = @content.menu_items.find(params[:id])
    _destroy @item
  end

  private

  def menu_item_params
    params.require(:item).permit(
      :concept_id, :layout_id, :name, :sitemap_state, :sort_no, :state, :title,
      :category_sets_attributes => [:id, :category_id, :layer],
      :creator_attributes => [:id, :group_id, :user_id]
    )
  end
end
