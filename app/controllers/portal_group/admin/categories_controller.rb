class PortalGroup::Admin::CategoriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    #default_url_options[:content] = @content
    
    if params[:parent] == '0'
      @parent = PortalGroup::Category.new({
        :level_no => 0
      })
      @parent.id = 0
    else
      @parent = PortalGroup::Category.new.find(params[:parent])
    end
  end

  def index
    @items = PortalGroup::Category.where(parent_id: @parent.id)
                                  .where(content_id: @content.id)
                                  .order(params[:sort] || :sort_no)
                                  .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end
  
  def show
    @item = PortalGroup::Category.new.find(params[:id])
    _show @item
  end

  def new
    @item = PortalGroup::Category.new({
      :state      => 'public',
      :sort_no    => 1,
    })
  end
  
  def create
    @item = PortalGroup::Category.new(category_params)
    @item.site_id    = Core.site.id
    @item.content_id = @content.id
    @item.parent_id  = @parent.id
    @item.level_no   = @parent.level_no + 1
    _create @item
  end
  
  def update
    @item = PortalGroup::Category.new.find(params[:id])
    @item.attributes = category_params
    _update @item
  end
  
  def destroy
    @item = PortalGroup::Category.new.find(params[:id])
    _destroy @item
  end

  private

  def category_params
    params.require(:item).permit(:concept_id, :in_creator, :layout_id, :name, :sort_no, :state, :title)
  end
end
