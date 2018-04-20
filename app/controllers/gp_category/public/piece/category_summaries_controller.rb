class GpCategory::Public::Piece::CategorySummariesController < GpCategory::Public::PieceController
  def pre_dispatch
    @piece = GpCategory::Piece::CategorySummary.find(Page.current_piece.id)
    @item = Page.current_item
  end

  def index
    case @item
    when GpCategory::CategoryType
      @category_type = @item
      render :category_type
    when GpCategory::Category
      @category = @item
      render :category
    else
      render plain: ''
    end
  end
end
