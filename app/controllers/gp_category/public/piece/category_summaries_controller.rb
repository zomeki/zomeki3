class GpCategory::Public::Piece::CategorySummariesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCategory::Piece::CategorySummary.find_by(id: Page.current_piece.id)
    render plain: '' unless @piece

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
