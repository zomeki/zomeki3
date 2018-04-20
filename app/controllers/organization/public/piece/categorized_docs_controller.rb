class Organization::Public::Piece::CategorizedDocsController < Organization::Public::PieceController
  def pre_dispatch
    @piece = Organization::Piece::CategorizedDoc.where(id: Page.current_piece.id).first
    return render plain: '' unless @piece

    @item = Page.current_item
  end

  def index
    return render plain: '' unless @item.is_a?(Organization::Group)  

    sys_group_ids = case @piece.page_filter
                    when 'self'
                      [@item.sys_group.id]
                    else
                      @item.public_descendants.map { |g| g.sys_group.id }
                    end

    @docs = @piece.content.docs
                  .organized_into(sys_group_ids)
                  .categorized_into(@piece.category_ids)
                  .order(@piece.docs_order_as_hash)
                  .limit(@piece.list_count)

    @docs = GpArticle::DocsPreloader.new(@docs).preload(:public_node_ancestors)
  end
end
