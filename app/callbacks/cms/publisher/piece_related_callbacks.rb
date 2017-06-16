class Cms::Publisher::PieceRelatedCallbacks < PublisherCallbacks
  def enqueue(item)
    @item = item
    return unless enqueue?
    enqueue_pieces
  end

  private

  def enqueue?
    return unless super
    @item.piece.state == 'public'
  end

  def enqueue_pieces
    Cms::Publisher::PieceCallbacks.new.enqueue(@item.piece)
  end
end
