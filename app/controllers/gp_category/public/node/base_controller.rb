class GpCategory::Public::Node::BaseController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed
  include GpArticle::Controller::Public::Scoping

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find_by(id: Page.current_node.content.id)
    return http_error(404) unless @content

    @more = (params[:file] =~ /^more($|@)/i)
    @more_options = params[:file].split('@', 3).drop(1) if @more
  end

  private

  def find_public_docs_with_category_id(category_id)
    GpArticle::Doc.categorized_into(category_id).except(:order).public_state
  end
end
