class GpArticle::Admin::Piece::MonthlyArchivesController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:num_docs_visibility]
  end
end
