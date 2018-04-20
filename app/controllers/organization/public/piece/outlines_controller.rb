class Organization::Public::Piece::OutlinesController < Organization::Public::PieceController
  def pre_dispatch
    @piece = Organization::Piece::Outline.find(Page.current_piece.id)
    @item = Page.current_item
    render plain: '' unless @item.kind_of?(Organization::Group)
  end

  def index
    render plain: @item.outline
  end
end
