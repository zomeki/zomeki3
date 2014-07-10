class PortalGroup::Admin::AttributesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    #default_url_options[:content] = @content
    @parent = 0
  end
  
  def index
    item = PortalGroup::Attribute.new#.readable
    item.and :content_id, @content
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = PortalGroup::Attribute.new.find(params[:id])
    _show @item
  end

  def new
    @item = PortalGroup::Attribute.new({
      :state      => 'public',
      :sort_no    => 1,
    })
  end
  
  def create
    @item = PortalGroup::Attribute.new(attribute_params)
    @item.site_id    = Core.site.id
    @item.content_id = @content.id
    _create @item
  end
  
  def update
    @item = PortalGroup::Attribute.new.find(params[:id])
    @item.attributes = attribute_params
    _update @item
  end
  
  def destroy
    @item = PortalGroup::Attribute.new.find(params[:id])
    _destroy @item
  end

  private

  def attribute_params
    params.require(:item).permit(:concept_id, :in_creator, :layout_id, :name, :sort_no, :state, :title)
  end
end
