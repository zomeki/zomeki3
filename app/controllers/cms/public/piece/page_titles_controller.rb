class Cms::Public::Piece::PageTitlesController < Cms::Controller::Public::Piece
  def index
    @title = Page.title
  end
end
