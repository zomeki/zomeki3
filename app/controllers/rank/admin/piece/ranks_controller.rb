class Rank::Admin::Piece::RanksController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:category_option, :display_count, :more_link_body, :more_link_url, :ranking_target, :ranking_term, :show_count]
  end
end
