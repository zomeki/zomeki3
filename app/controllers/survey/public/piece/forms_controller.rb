class Survey::Public::Piece::FormsController < Sys::Controller::Public::Base
  include Survey::Controller::Public::Scoping

  def pre_dispatch
    @piece = Survey::Piece::Form.find_by(id: Page.current_piece.id)
    return render plain: '' unless @piece

    @item = Page.current_item
  end

  def index
    public_node = @piece.content.public_node
    return render plain: '' unless public_node

    @form = @piece.target_form
    return render plain: '' unless @form
  end
end
