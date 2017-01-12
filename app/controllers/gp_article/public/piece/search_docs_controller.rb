class GpArticle::Public::Piece::SearchDocsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpArticle::Piece::SearchDoc.find_by(id: Page.current_piece.id)
    return render plain: '' unless @piece

    @node = @piece.content.public_search_docs_node
    return render plain: '' unless @node
  end

  def index
    @s_keyword = params[:s_keyword].to_s
  end
end
