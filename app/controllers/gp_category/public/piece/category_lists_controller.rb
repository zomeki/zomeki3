class GpCategory::Public::Piece::CategoryListsController < GpCategory::Public::PieceController
  def pre_dispatch
    @piece = GpCategory::Piece::CategoryList.find(Page.current_piece.id)
    @item = Page.current_item
  end

  def index
    if @piece.setting_state == 'enabled'
      if @piece.category_type_id && @piece.category_id
        @category = @piece.category_type.categories.find(@piece.category_id)
        render :category
      elsif @piece.category_type_id
        @category_type = @piece.category_type
        return render plain: '' unless @category_type
        render :category_type
      else
        @category_types = @piece.public_category_types
      end
    else
      case @item
      when GpCategory::CategoryType
        @category_type = @item
        render :category_type
      when GpCategory::Category
        @category = @item
        render :category
      else
        @category_types = @piece.public_category_types
      end
    end
  end
end
