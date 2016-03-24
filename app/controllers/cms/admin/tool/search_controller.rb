# encoding: utf-8
class Cms::Admin::Tool::SearchController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
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
    
    group = [ "ページ", [] ]
    Cms::Node.where(site_id: Core.site.id, model: "Cms::Page")
      .search_with_text(:title, :body, :mobile_title, :mobile_body, @item.keyword)
      .order(:id)
      .each {|c| group[1] << [c.id, c.title, c.admin_uri] }
    @items << group

    Cms::Content.where(site_id: Core.site.id, model: "GpArticle::Doc").order(:id).each do |content|
      group = [ "記事：#{content.name}", [] ]
      GpArticle::Doc.where(content_id: content.id)
        .search_with_text(:title, :subtitle, :summary, :body, :mobile_title, :mobile_body, @item.keyword)
        .order(:id)
        .each {|c| group[1] << [c.id, c.title, gp_article_doc_path(c.content, c.id)] }
      @items << group
    end
  end
end
