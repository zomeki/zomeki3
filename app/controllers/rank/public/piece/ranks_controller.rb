class Rank::Public::Piece::RanksController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Rank::Piece::Rank.find_by(id: Page.current_piece.id)
    render plain: '' unless @piece
  end

  def index
    render plain: '' and return if @piece.ranking_target.blank? || @piece.ranking_term.blank?

    @ranks = Rank::TotalsFinder.new(@piece.content.ranks)
                               .search(@piece.content, @piece.ranking_term, @piece.ranking_target, category_option: @piece.category_option, current_item: Page.current_item)
                               .paginate(page: params[:page], per_page: @piece.display_count)
    render plain: '' if @ranks.empty?
  end
end
