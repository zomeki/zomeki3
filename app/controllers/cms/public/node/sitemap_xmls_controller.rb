class Cms::Public::Node::SitemapXmlsController < Cms::Controller::Public::Base
  include GpArticle::Controller::Public::Scoping

  def index
    @item = Page.current_node

    Page.current_item = @item
    Page.title        = @item.title

    @items = Cms::Node.public_state
                      .where(parent_id: Page.site.root_node.id)
                      .where.not(name: nil)
                      .order(directory: :desc, sitemap_sort_no: :asc, name: :asc)

    render :index, formats: [:xml]
  end
end
