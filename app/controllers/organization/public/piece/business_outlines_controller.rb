class Organization::Public::Piece::BusinessOutlinesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Organization::Piece::BusinessOutline.where(id: Page.current_piece.id).first
    render plain: '' unless @piece

    @item = Page.current_item
  end

  def index
    render plain: (@item.kind_of?(Organization::Group) ? @item.business_outline : '')
  end
end
