class Tag::Public::Piece::TagsController < Tag::Public::PieceController
  def pre_dispatch
    @piece = Tag::Piece::Tag.find(Page.current_piece.id)
  end

  def index
    @tags = @piece.content.tags
    @tags = Cms::ContentsPreloader.new(@tags).preload(:public_node_ancestors)
  end
end
