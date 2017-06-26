class GpCategory::Publisher::CategoryCallbacks < PublisherCallbacks
  def enqueue(category)
    @category = category
    return unless enqueue?
    enqueue_pieces
    enqueue_categories
    enqueue_docs
  end

  private

  def enqueue?
    return unless super
    [@category.state, @category.state_was].include?('public')
  end

  def enqueue_pieces
    pieces = @category.content.public_pieces.sort { |p| p.model == 'GpCategory::RecentTab' ? 1 : 9 }
    Cms::Publisher::PieceCallbacks.new.enqueue(pieces)
  end

  def enqueue_categories
    Cms::Publisher.register(@category.content.site_id, @category.public_ancestors)
  end

  def enqueue_docs
    category_ids = @category.public_descendants.map(&:id)
    docs = GpArticle::Doc.public_state.categorized_into(category_ids).select(:id)
    Cms::Publisher.register(@category.content.site_id, docs)
  end
end
