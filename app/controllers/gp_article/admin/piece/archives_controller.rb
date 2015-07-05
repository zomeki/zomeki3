class GpArticle::Admin::Piece::ArchivesController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:num_docs_visibility, :order, :term]
  end
end
