class Gnav::Public::Piece::DocsController < Gnav::Public::PieceController
  def pre_dispatch
    @piece = Gnav::Piece::Doc.find(Page.current_piece.id)
    @item = Page.current_item
  end

  def index
    piece_category_ids = @piece.categories.map(&:id)

    piece_doc_ids = GpArticle::Doc.categorized_into(piece_category_ids).pluck(:id)

    doc_ids = 
      case @item
      when Gnav::MenuItem
        page_category_ids = @item.categories.map(&:id)
        page_doc_ids = GpArticle::Doc.categorized_into(page_category_ids).pluck(:id)
        piece_doc_ids & page_doc_ids
      else
        piece_doc_ids
      end

    @docs = GpArticle::Doc.where(id: doc_ids)
                          .order(display_published_at: :desc, published_at: :desc)
                          .limit(@piece.list_count)

    @docs = GpArticle::DocsPreloader.new(@docs).preload(:public_node_ancestors)
  end
end
