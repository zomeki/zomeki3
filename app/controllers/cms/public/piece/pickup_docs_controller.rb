class Cms::Public::Piece::PickupDocsController < Cms::Controller::Public::Piece
  def pre_dispatch
    @piece = Cms::Piece::PickupDoc.find(Page.current_piece.id)
  end

  def index
    @docs = []
    Cms::Piece::PickupDocXml.find(:all, @piece, order: :sort_no).each do |doc|
      next if doc.doc.blank?
      @docs << doc.doc
    end
  end
end
