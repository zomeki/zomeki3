# encoding: utf-8
class GpArticle::Public::Piece::DocsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpArticle::Piece::Doc.find_by(id: Page.current_piece.id)
    render :text => '' unless @piece

    @item = Page.current_item
  end

  def index
    @docs = @piece.content.public_docs.limit(@piece.docs_number)
    @docs = case @piece.docs_order
            when 'published_at_desc'
              @docs.order('display_published_at DESC, published_at DESC')
            when 'published_at_asc'
              @docs.order('display_published_at ASC, published_at ASC')
            when 'random'
              @docs.order('RAND()')
            else
              @docs
            end
    @docs = @docs.preload_public_node_ancestors.preload_creator

    render :index_mobile if Page.mobile?
  end
end
