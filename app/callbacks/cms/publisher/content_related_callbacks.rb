class Cms::Publisher::ContentRelatedCallbacks < PublisherCallbacks
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
    Cms::Publisher.register(@item.content.site_id, @item.content.public_nodes.select(:id, :parent_id, :name))
  end

  def enqueue_pieces
    @item.content.public_pieces.each do |piece|
      Cms::Publisher::PieceCallbacks.new.enqueue(piece)
    end
  end
end
