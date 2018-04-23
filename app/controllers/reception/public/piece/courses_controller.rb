class Reception::Public::Piece::CoursesController < Reception::Public::PieceController
  def pre_dispatch
    @piece = Reception::Piece::Course.find(Page.current_piece.id)
    @item = Page.current_item
  end

  def index
    @courses = @piece.content.public_courses
    @courses = @piece.apply_docs_criteria(@courses)
  end
end
