class GpCategory::Publisher::CategoryTypeCallbacks < PublisherCallbacks
  def enqueue(category_type)
    @category_type = category_type
    return unless enqueue?
    enqueue_pieces
    enqueue_categories
    enqueue_docs
  end

  private

  def enqueue?
    return unless super
    [@category_type.state, @category_type.state_was].include?('public')
  end

  def enqueue_pieces
    pieces = @category_type.content.public_pieces.sort { |p| p.model == 'GpCategory::RecentTab' ? 1 : 9 }
    Cms::Publisher::PieceCallbacks.new.enqueue(pieces)
  end

  def enqueue_categories
    Cms::Publisher.register(@category_type.content.site_id, @category_type.public_categories)
  end

  def enqueue_docs
    category_ids = @category_type.public_categories.pluck(:id)
    docs = GpArticle::Doc.public_state.categorized_into(category_ids).select(:id)
    Cms::Publisher.register(@category_type.content.site_id, docs)
  end
end
