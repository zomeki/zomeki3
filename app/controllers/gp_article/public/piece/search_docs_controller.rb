class GpArticle::Public::Piece::SearchDocsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpArticle::Piece::SearchDoc.find_by(id: Page.current_piece.id)
    return render plain: '' unless @piece

    @node = @piece.content.public_search_docs_node
    return render plain: '' unless @node
  end

  def index
    @keyword = params.dig(:criteria, :keyword)
    @category_ids = params.dig(:criteria, :category_ids) || []
  end
end
