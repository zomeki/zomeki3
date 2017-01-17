require 'will_paginate/array'
class GpArticle::Public::Node::SearchDocsController < Cms::Controller::Public::Base
  def pre_dispatch
    @content = GpArticle::Content::Doc.find_by(id: Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    @keyword = params.dig(:criteria, :keyword)
    @category_ids = params.dig(:criteria, :category_ids) || []

    @docs = @content.public_docs
    @docs = @docs.search_with_text(:title, :body, @keyword) if @keyword.present?
    @docs = @docs.categorized_into(@category_ids) if @category_ids.present?
    @docs = @docs.order(display_published_at: :desc, published_at: :desc)
                 .paginate(page: params[:page], per_page: 20)
    return http_error(404) if @docs.current_page > @docs.total_pages
  end
end
