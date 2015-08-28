class GpArticle::Admin::Piece::DocsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:date_style, :doc_style, :docs_number, :docs_order, :more_link_body, :more_link_url]
  end
end
