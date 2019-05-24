class GpArticle::Public::Piece::SearchDocsController < GpArticle::Public::PieceController
  def pre_dispatch
    @piece = GpArticle::Piece::SearchDoc.find(Page.current_piece.id)
    @node = @piece.content.public_search_docs_node
    return render plain: '' unless @node
  end

  def index
    @keyword = params.dig(:criteria, :keyword)
    @operator_type = @piece.operator_type == 'or' ? 'or' : 'and'
    @category_ids = params.dig(:criteria, :category_ids) || []
    @category_type_ids = params.dig(:criteria, :category_type_ids) || {}

    if @operator_type == 'and' && @category_type_ids.present?
      @category_ids = []
      @category_type_ids.values.each{|c| @category_ids.concat(Array(c)) }
    end
  end
end
