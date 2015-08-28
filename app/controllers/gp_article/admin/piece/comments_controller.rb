class GpArticle::Admin::Piece::CommentsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:authors_visibility, :docs_number]
  end
end
