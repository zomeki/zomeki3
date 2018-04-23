class Organization::Public::Piece::ContactInformationsController < Organization::Public::PieceController
  def pre_dispatch
    @piece = Organization::Piece::ContactInformation.find(Page.current_piece.id)
    @item = Page.current_item
    render plain: '' unless @item.kind_of?(Organization::Group)
  end

  def index
  end
end
