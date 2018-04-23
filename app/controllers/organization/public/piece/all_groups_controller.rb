class Organization::Public::Piece::AllGroupsController < Organization::Public::PieceController
  def pre_dispatch
    @piece = Organization::Piece::AllGroup.find(Page.current_piece.id)
    @item = Page.current_item
  end

  def index
    @groups = @piece.content.top_layer_groups.public_state
    @groups = Cms::ContentsPreloader.new(@groups).preload(:public_node_ancestors)
  end
end
