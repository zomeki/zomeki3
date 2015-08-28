class Cms::Admin::Piece::PickupDocsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:date_style, :list_style]
  end
end
