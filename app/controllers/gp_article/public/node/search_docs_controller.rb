require 'will_paginate/array'
class GpArticle::Public::Node::SearchDocsController < Cms::Controller::Public::Base
  def pre_dispatch
    @content = GpArticle::Content::Doc.find_by(id: Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    @s_keyword = params[:s_keyword].to_s

    if @s_keyword.blank?
      @docs = []
    else
      @docs = @content.public_docs.search_with_text(:title, :body, @s_keyword)
                      .order('display_published_at DESC, published_at DESC')
                      .paginate(page: params[:page], per_page: 20)
      return http_error(404) if @docs.current_page > @docs.total_pages
    end
  end
end
