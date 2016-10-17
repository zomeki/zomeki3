class Gnav::Public::Piece::CategoryTypesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Gnav::Piece::CategoryType.find_by(id: Page.current_piece.id)
    render plain: '' unless @piece

    @item = Page.current_item
  end

  def index
    piece_categories = @piece.public_categories

    @categories = 
      case @item
      when Gnav::MenuItem
        page_categories = @item.categories
        piece_categories & page_categories
      else
        piece_categories
      end

    @least_level_no = @categories.min{|a, b| a.level_no <=> b.level_no }.try(:level_no).to_i
    @categories.reject! {|c| c.level_no > (@least_level_no + 1) }
  end
end
