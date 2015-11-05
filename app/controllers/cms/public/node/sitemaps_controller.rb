# encoding: utf-8
class Cms::Public::Node::SitemapsController < Cms::Controller::Public::Base
  def index
    @item = Page.current_node

    Page.current_item = @item
    Page.title        = @item.title

    @items = Cms::Node.public_state.where(route_id: Page.site.root_node.id, sitemap_state: 'visible')
      .where.not(name: nil)
      .order('directory DESC, sitemap_sort_no IS NULL, sitemap_sort_no, name')
      .preload_assocs(:public_descendants_in_route_assocs)

    @children = lambda do |node|
      item = Cms::Node.public_state.where(route_id: node.id, sitemap_state: 'visible')
        .where.not(name: nil)
        .order('directory DESC, sitemap_sort_no IS NULL, sitemap_sort_no, name')
    end
  end
end
