class GpCategory::Public::Piece::RecentTabsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCategory::Piece::RecentTab.find_by(id: Page.current_piece.id)
    render plain: '' unless @piece
  end

  def index
    @more_label = @piece.more_label.presence || '>>新着記事一覧'
    @tabs = []

    GpCategory::Piece::RecentTabXml.find(:all, @piece, :order => :sort_no).each do |tab|
      next if tab.name.blank?

      tab_class =
        if (current = @tabs.empty?)
          "#{tab.name} current"
        else
          tab.name
        end

      content_ids = GpArticle::Content::Setting.where(name: 'gp_category_content_category_type_id',
                                                      value: @piece.content.id).pluck(:content_id)
      docs =
        unless tab.categories_with_layer.empty?
          GpArticle::Doc.where(id: tab.public_doc_ids)
        else
          GpArticle::Doc
        end
      docs = docs.mobile(::Page.mobile?).public_state.where(content_id: content_ids)
                 .order(display_published_at: :desc, published_at: :desc)
                 .limit(@piece.list_count)
      docs = GpArticle::DocsPreloader.new(docs).preload(:public_node_ancestors)

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
end
