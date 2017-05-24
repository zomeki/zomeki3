class GpCategory::Publisher::CategoryCallbacks < PublisherCallbacks
  def after_save(category)
    @category = category
    enqueue if enqueue?
  end

  def before_destroy(category)
    @category = category
    enqueue if enqueue?
  end

  def enqueue(category = nil)
    @category = category if category
    enqueue_pieces
    enqueue_categories
    enqueue_docs
    enqueue_sitemap_nodes
  end

  private

  def enqueue?
    [@category.state, @category.state_was].include?('public')
  end

  def enqueue_pieces
    pieces = @category.content.public_pieces.sort { |p| p.model == 'GpCategory::RecentTab' ? 1 : 9 }
    pieces.each do |piece|
      Cms::Publisher::PieceCallbacks.new.enqueue(piece)
    end
  end

  def enqueue_categories
    Cms::Publisher.register(@category.content.site_id, @category.public_ancestors)
  end

  def enqueue_docs
    category_ids = @category.public_descendants.map(&:id)
    docs = GpArticle::Doc.public_state.categorized_into(category_ids).select(:id)
    Cms::Publisher.register(@category.content.site_id, docs)
  end

  def enqueue_sitemap_nodes
    if [@category.sitemap_state, @category.sitemap_state_was].include?('visible')
      site = @category.content.site
      Cms::Publisher.register(site.id, site.public_sitemap_nodes)
    end
  end
end
