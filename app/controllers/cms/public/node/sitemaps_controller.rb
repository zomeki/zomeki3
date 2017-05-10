class Cms::Public::Node::SitemapsController < Cms::Controller::Public::Base
  def index
    @item = Page.current_node

    Page.current_item = @item
    Page.title        = @item.title

    @items = Cms::Node.public_state.visible_in_sitemap.where(route_id: Page.site.root_node.id)
      .where.not(name: nil)
      .order('directory DESC, sitemap_sort_no IS NULL, sitemap_sort_no, name')
      .preload_assocs(:public_descendants_in_route_assocs)
  end
end
