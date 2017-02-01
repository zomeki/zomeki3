class GpArticle::Admin::Piece::SearchDocsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item
    super + [in_category_type_ids: []]
  end
end
