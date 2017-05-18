class GpCategory::Publisher::CategoryTypeCallbacks < PublisherCallbacks
  def after_save(category_type)
    @category_type = category_type
    enqueue if enqueue?
  end

  def before_destroy(category_type)
    @category_type = category_type
    enqueue if enqueue?
  end

  def enqueue(category_type = nil)
    @category_type = category_type if category_type
    enqueue_pieces
    enqueue_categories
    enqueue_docs
    enqueue_sitemap_nodes
  end

  private

  def enqueue?
    [@category_type.state, @category_type.state_was].include?('public')
  end

  def enqueue_pieces
    pieces = @category_type.content.public_pieces.sort { |p| p.model == 'GpCategory::RecentTab' ? 1 : 9 }
    pieces.each do |piece|
      Cms::Publisher::PieceCallbacks.new.enqueue(piece)
    end
  end

  def enqueue_categories
    Cms::Publisher.register(@category_type.content.site_id, @category_type.public_categories)
  end

  def enqueue_docs
    category_ids = @category_type.public_categories.pluck(:id)
    docs = GpArticle::Doc.public_state.categorized_into(category_ids).select(:id)
    Cms::Publisher.register(@category_type.content.site_id, docs)
  end

  def enqueue_sitemap_nodes
    if [@category_type.sitemap_state, @category_type.sitemap_state_was].include?('visible')
      site = @category_type.content.site
      Cms::Publisher.register(site.id, site.public_sitemap_nodes)
    end
  end
end
