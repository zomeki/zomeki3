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
  end

  private

  def enqueue?
    true
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
    docs = @category.public_descendants.flat_map { |c| c.docs.public_state.select(:id) }
    Cms::Publisher.register(@category.content.site_id, docs)
  end
end
