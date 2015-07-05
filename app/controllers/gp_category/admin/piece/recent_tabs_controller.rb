class GpCategory::Admin::Piece::RecentTabsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:date_style, :list_count, :list_style, :more_label]
  end
end
