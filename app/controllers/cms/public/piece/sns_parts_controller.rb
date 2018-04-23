class Cms::Public::Piece::SnsPartsController < Cms::Controller::Public::Piece
  def pre_dispatch
    @piece = Cms::Piece::SnsPart.find(Page.current_piece.id)
  end
end
