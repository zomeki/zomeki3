class Cms::Publisher::ContentCallbacks < PublisherCallbacks
  def initialize(belonged: false)
    @belonged = belonged
  end

  def enqueue(item)
    @item = item
    @content = @belonged ? @item.content : @item
    return unless enqueue?
    enqueue_nodes
    enqueue_pieces
  end

  private

  def enqueue?
    return unless super
    [@item.state, @item.state_was].include?('public')
  end

  def enqueue_nodes
    Cms::Publisher.register(@content.site_id, @content.public_nodes)
  end

  def enqueue_pieces
    @content.public_pieces.each do |piece|
      Cms::Publisher::PieceCallbacks.new.enqueue(piece)
    end
  end
end
