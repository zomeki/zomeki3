class Cms::Public::Piece::PickupDocsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Cms::Piece::PickupDoc.find_by(id: Page.current_piece.id)
    render plain: '' unless @piece
  end

  def index
    @docs = []
    Cms::Piece::PickupDocXml.find(:all, @piece, :order => :sort_no).each do |doc|
      next if doc.doc.blank?
      @docs << doc.doc
    end
  end
end
