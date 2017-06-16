class Cms::Publisher::ContentRelatedCallbacks < PublisherCallbacks
  def enqueue(item)
    @item = item
    return unless enqueue?
    enqueue_nodes
    enqueue_pieces
  end

  private

  def enqueue?
    return unless super
    !@item.respond_to?(:state) || [@item.state, @item.state_was].include?('public')
  end

  def enqueue_nodes
    Cms::Publisher.register(@item.content.site_id, @item.content.public_nodes)
  end

  def enqueue_pieces
    @item.content.public_pieces.each do |piece|
      Cms::Publisher::PieceCallbacks.new.enqueue(piece)
    end
  end
end
