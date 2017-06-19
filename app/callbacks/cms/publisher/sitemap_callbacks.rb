class Cms::Publisher::SitemapCallbacks < PublisherCallbacks
  def enqueue(item)
    @item = item
    return unless enqueue?
    enqueue_sitemap_nodes
  end

  private

  def enqueue?
    return unless super
    [@item.state, @item.state_was].include?('public') && [@item.sitemap_state, @item.sitemap_state_was].include?('visible')
  end

  def enqueue_sitemap_nodes
    Cms::Publisher.register(@item.site.id, @item.site.public_sitemap_nodes)
  end
end
