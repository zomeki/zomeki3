class GpArticle::Public::Piece::SearchDocsController < GpArticle::Public::PieceController
  def pre_dispatch
    @piece = GpArticle::Piece::SearchDoc.find(Page.current_piece.id)
    @node = @piece.content.public_search_docs_node
    return render plain: '' unless @node
  end

  def index
    @keyword = params.dig(:criteria, :keyword)
    @category_ids = params.dig(:criteria, :category_ids) || []
  end
end
