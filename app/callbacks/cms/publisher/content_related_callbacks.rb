class Cms::Publisher::ContentRelatedCallbacks < PublisherCallbacks
  def after_save(item)
    @item = item
    enqueue if enqueue?
  end

  def before_destroy(item)
    @item = item
    enqueue if enqueue?
  end

  def enqueue(item = nil)
    @item = item if item
    enqueue_nodes
    enqueue_pieces
    enqueue_sitemap_nodes
  end

  private

  def enqueue?
    !@item.respond_to?(:state) || [@item.state, @item.state_was].include?('public')
  end

  def enqueue_nodes
    Cms::Publisher.register(@item.content.site_id, @item.content.public_nodes)
  end

  def enqueue_pieces
    @item.content.public_pieces.each do |piece|
      Cms::Publisher::PieceCallbacks.new.enqueue(piece)
    end
  end

  def enqueue_sitemap_nodes
    return unless @item.respond_to?(:sitemap_state)

    if [@item.sitemap_state, @item.sitemap_state_was].include?('visible')
      site = @item.content.site
      Cms::Publisher.register(site.id, site.public_sitemap_nodes)
    end
  end
end
