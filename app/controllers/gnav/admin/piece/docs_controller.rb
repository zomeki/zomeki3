class Gnav::Admin::Piece::DocsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:category_id, :category_type_id, :date_style, :list_count, :list_style]
  end
end
