class Rank::Public::Piece::RanksController < Sys::Controller::Public::Base
  include Rank::Controller::Rank

  def pre_dispatch
    @piece = Rank::Piece::Rank.find_by(id: Page.current_piece.id)
    render plain: '' unless @piece
  end

  def index
    render plain: '' and return if @piece.ranking_target.blank? || @piece.ranking_term.blank?

    @term   = @piece.ranking_term
    @target = @piece.ranking_target
    @ranks  = rank_datas(@piece.content, @term, @target, @piece.display_count, @piece.category_option)

    render plain: '' if @ranks.empty?
  end
end
