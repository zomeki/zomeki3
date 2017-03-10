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
  end

  private

  def enqueue?
    true
  end

  def enqueue_pieces
    pieces = @category_type.content.public_pieces.sort { |p| p.model == 'GpCategory::RecentTab' ? 1 : 9 }
    pieces.each do |piece|
      Cms::Publisher::PieceCallbacks.new.enqueue(piece)
    end
  end

  def enqueue_categories
    Cms::Publisher.register(@category_type.content.site_id, @category_type.public_categories.select(:id))
  end

  def enqueue_docs
    docs = @category_type.public_categories.flat_map { |c| c.docs.public_state.select(:id) }
    Cms::Publisher.register(@category_type.content.site_id, docs.uniq)
  end
end
