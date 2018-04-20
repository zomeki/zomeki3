class Survey::Public::Piece::FormsController < Survey::Public::PieceController
  def pre_dispatch
    @piece = Survey::Piece::Form.find(Page.current_piece.id)
    @item = Page.current_item
    render plain: '' unless @piece.content.public_node
  end

  def index
    @form = @piece.target_form
    return render plain: '' unless @form
  end
end
