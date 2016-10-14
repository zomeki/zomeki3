class Cms::Public::Piece::SnsPartsController < Sys::Controller::Public::Base
  def pre_dispatch
    render plain: '' unless @piece = Cms::Piece::SnsPart.find_by(id: Page.current_piece.id)
  end
end
