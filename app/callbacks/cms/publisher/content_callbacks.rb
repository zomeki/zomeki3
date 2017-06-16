class Cms::Publisher::ContentCallbacks < PublisherCallbacks
  def enqueue(item)
    @item = item
    return unless enqueue?
    enqueue_nodes
    enqueue_pieces
  end

  private

  def enqueue_nodes
    Cms::Publisher.register(@item.site_id, @item.public_nodes)
  end

  def enqueue_pieces
    @item.public_pieces.each do |piece|
      Cms::Publisher::PieceCallbacks.new.enqueue(piece)
    end
  end
end
