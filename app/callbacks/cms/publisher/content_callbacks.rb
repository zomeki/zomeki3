class Cms::Publisher::ContentCallbacks < PublisherCallbacks
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
  end

  private

  def enqueue?
    true
  end

  def enqueue_nodes
    Cms::Publisher.register(@item.site_id, @item.public_nodes)
  end

  def enqueue_pieces
    @item.public_pieces.each do |piece|
      Cms::Publisher::PieceCallbacks.new.enqueue(piece)
    end
  end
end
