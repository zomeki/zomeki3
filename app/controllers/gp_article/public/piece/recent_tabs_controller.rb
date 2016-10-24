class GpArticle::Public::Piece::RecentTabsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpArticle::Piece::RecentTab.find_by(id: Page.current_piece.id)
    render plain: '' unless @piece
  end

  def index
    @more_label = @piece.more_label.presence || '>>新着記事一覧'
    @tabs = []

    GpArticle::Piece::RecentTabXml.find(:all, @piece, order: :sort_no).each do |tab|
      next if tab.name.blank?

      tab_class =
        if (current = @tabs.empty?)
          "#{tab.name} current"
        else
          tab.name
        end

      docs =
        unless tab.categories_with_layer.empty?
          @piece.content.public_docs_for_list.where(id: tab.public_doc_ids)
        else
          @piece.content.public_docs_for_list
        end
      docs = docs.order(display_published_at: :desc, published_at: :desc)
                 .limit(@piece.list_count)
                 .preload_assocs(:public_node_ancestors_assocs, :public_index_assocs)

      @tabs.push(name: tab.name,
                 title: tab.title,
                 class: tab_class,
                 more: tab.more.presence,
                 more_dir: tab.more_dir,
                 current: current,
                 docs: docs)
    end

    render plain: '' if @tabs.empty?
  end

  private


end
