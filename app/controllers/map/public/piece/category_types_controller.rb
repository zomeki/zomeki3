class Map::Public::Piece::CategoryTypesController < Map::Public::PieceController
  def pre_dispatch
    @piece = Map::Piece::CategoryType.find(Page.current_piece.id)
    @item = Page.current_item
  end

  def index
    @top_categories = @piece.content.public_categories.where(category_type_id: @piece.visible_category_type_ids)
    @top_categories = GpCategory::CategoriesPreloader.new(@top_categories).preload(:public_descendants)
  end
end
