class Cms::Public::Piece::PageTitlesController < Sys::Controller::Public::Base
  def index
    @title = Page.title
  end
end
