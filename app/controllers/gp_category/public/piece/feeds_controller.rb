class GpCategory::Public::Piece::FeedsController < GpCategory::Public::PieceController
  def pre_dispatch
    @piece = GpCategory::Piece::Feed.find(Page.current_piece.id)
    @item = Page.current_item
  end
  
  def index
    case @item
    when Cms::Node
      @feed = true if @item.model == 'GpCategory::Doc'
    when GpCategory::Category
      @feed = true 
    end
  end
end
