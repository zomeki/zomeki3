class Rank::Admin::Piece::RanksController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:ranking_target, :ranking_term, :display_count, :show_count, :more_link_body, :more_link_url, :category_option]
  end
end
