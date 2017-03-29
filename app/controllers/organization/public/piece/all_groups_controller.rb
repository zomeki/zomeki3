class Organization::Public::Piece::AllGroupsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Organization::Piece::AllGroup.where(id: Page.current_piece.id).first
    return render plain: '' unless @piece

    @item = Page.current_item
  end

  def index
    @groups = @piece.content.top_layer_groups.public_state
                    .preload_assocs(:public_node_ancestors_assocs)
  end
end
