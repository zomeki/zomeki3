class Cms::Publisher::NodeCallbacks < PublisherCallbacks
  def enqueue(node)
    @node = node
    @site = @node.site
    return unless enqueue?
    enqueue_nodes
    enqueue_sitemaps
  end

  private

  def enqueue?
    return unless super
    @node.name.present? && [@node.state, @node.state_was].include?('public')
  end

  def enqueue_nodes
    return if @node.model.in?(%w(Cms::Page Cms::Sitemap))
    Cms::Publisher.register(@site.id, @node)
  end

  def enqueue_sitemaps
    nodes = @site.nodes.where(model: 'Cms::SitemapXml')
    Cms::Publisher.register(@site.id, nodes)
   end
end
