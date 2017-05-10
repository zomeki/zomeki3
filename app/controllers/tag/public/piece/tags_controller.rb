class Tag::Public::Piece::TagsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Tag::Piece::Tag.find_by(id: Page.current_piece.id)
    render plain: '' unless @piece
  end

  def index
    @tags = @piece.content.tags
    @tags = Cms::ContentPreloader.new(@tags).preload(:public_node_ancestors)
    render plain: '' if @tags.empty?
  end
end
