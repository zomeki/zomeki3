class GpArticle::Admin::Piece::RecentTabsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:date_style, :list_count, :docs_order, :list_style, :more_label]
  end
end
