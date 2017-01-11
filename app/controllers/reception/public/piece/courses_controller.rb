class Reception::Public::Piece::CoursesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Reception::Piece::Course.find_by(id: Page.current_piece.id)
    render plain: '' unless @piece

    @item = Page.current_item
  end

  def index
    @courses = @piece.content.public_courses
    @courses = @piece.apply_docs_criteria(@courses)
  end
end
