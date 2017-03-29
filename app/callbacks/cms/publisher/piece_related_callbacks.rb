class Cms::Publisher::PieceRelatedCallbacks < PublisherCallbacks
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
    enqueue_pieces
  end

  private

  def enqueue?
    true
  end

  def enqueue_pieces
    Cms::Publisher::PieceCallbacks.new.enqueue(@item.piece) if @item.piece.state == 'public'
  end
end
