class Cms::Admin::Tool::SearchController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:creator)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @item  = []
    @items = []
    def @item.keyword ; @keyword ; end
    def @item.keyword=(v) ; @keyword = v ; end
    return true if params[:do] != 'search'
    return true if params[:item][:keyword].blank?
    @item.keyword = params[:item][:keyword]

    if params[:target] && params[:target][:node_page] && Core.user.has_auth?(:designer)
      group = [ "固定ページ", [] ]
      Cms::Node.where(site_id: Core.site.id, model: "Cms::Page", concept_id: Core.concept(:id))
        .search_with_text(:title, :body, :mobile_title, :mobile_body, @item.keyword)
        .order(:id)
        .each {|c| group[1] << [c.id, c.title, c.admin_uri] }
      @items << group
    end

    if params[:target] && params[:target][:gp_article]
      Cms::Content.where(site_id: Core.site.id, model: "GpArticle::Doc", concept_id: Core.concept(:id)).order(:id).each do |content|
        group = [ "記事：#{content.name}", [] ]
        GpArticle::Doc.where(content_id: content.id)
          .search_with_text(:title, :subtitle, :summary, :body, :mobile_title, :mobile_body, @item.keyword)
          .order(:id)
          .each {|c| group[1] << [c.id, c.title, gp_article_doc_path(c.content, c.id)] }
        @items << group
      end
    end

    if params[:target] && params[:target][:piece] && Core.user.has_auth?(:designer)
      group = [ "ピース", [] ]
      Cms::Piece.where(site_id: Core.site.id, concept_id: Core.concept(:id))
        .search_with_text(:name, :title, :view_title, :head, :body, @item.keyword)
        .order(:id)
        .each {|c| group[1] << [c.id, c.title, cms_piece_path(c.concept_id, c.id)] }
      @items << group
    end

    if params[:target] && params[:target][:layout] && Core.user.has_auth?(:designer)
      group = [ "レイアウト", [] ]
      Cms::Layout.where(site_id: Core.site.id, concept_id: Core.concept(:id))
        .search_with_text(:name, :title, :head, :body, :mobile_head, :mobile_body, @item.keyword)
        .order(:id)
        .each {|c| group[1] << [c.id, c.title, cms_layout_path(c.concept_id, c.id)] }
      @items << group
    end

    if params[:target] && params[:target][:data_text]
      group = [ "テキスト", [] ]
      Cms::DataText.where(site_id: Core.site.id, concept_id: Core.concept(:id))
        .search_with_text(:name, :title, :body, @item.keyword)
        .order(:id)
        .each {|c| group[1] << [c.id, c.title, cms_data_text_path(c.concept_id, c.id)] }
      @items << group
    end

    if params[:target] && params[:target][:data_file]
      group = [ "ファイル", [] ]
      Cms::DataFile.where(site_id: Core.site.id, concept_id: Core.concept(:id))
        .search_with_text(:name, :title, @item.keyword)
        .order(:id)
        .each {|c| group[1] << [c.id, c.title, cms_data_file_path(c.concept_id, c.id)] }
      @items << group
    end
  end
end
