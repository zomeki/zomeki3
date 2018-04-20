class Organization::Public::Piece::BusinessOutlinesController < Organization::Public::PieceController
  def pre_dispatch
    @piece = Organization::Piece::BusinessOutline.find(Page.current_piece.id)
    @item = Page.current_item
    render plain: '' unless @item.kind_of?(Organization::Group)
  end

  def index
    render plain: @item.business_outline
  end
end
