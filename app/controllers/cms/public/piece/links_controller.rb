class Cms::Public::Piece::LinksController < Cms::Controller::Public::Piece
  def index
    @piece = Cms::Piece::Link.find(Page.current_piece.id)
  end
end
