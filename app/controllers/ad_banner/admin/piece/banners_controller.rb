class AdBanner::Admin::Piece::BannersController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:group_id, :impl, :lower_text, :sort, :upper_text]
  end
end
