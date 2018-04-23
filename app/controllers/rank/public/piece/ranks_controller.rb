class Rank::Public::Piece::RanksController < Rank::Public::PieceController
  def pre_dispatch
    @piece = Rank::Piece::Rank.find(Page.current_piece.id)
    render plain: '' if @piece.ranking_target.blank? || @piece.ranking_term.blank?
  end

  def index
    @ranks = Rank::TotalsFinder.new(@piece.content.ranks)
                               .search(@piece.content, @piece.ranking_term, @piece.ranking_target, category_option: @piece.category_option, current_item: Page.current_item)
                               .paginate(page: params[:page], per_page: @piece.display_count)
  end
end
