class GpCategory::Public::Node::BaseController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed

  def pre_dispatch
    @content = GpCategory::Content::CategoryType.find_by(id: Page.current_node.content.id)
    return http_error(404) unless @content
    @more = (params[:file] =~ /^more($|_)/i)
    @more_options = params[:file].split('_', 2)[1].to_s.split('@') if @more
  end

  private

  def find_public_docs_with_category_id(category_id)
    GpArticle::Doc.categorized_into(category_id).except(:order).mobile(::Page.mobile?).public_state
  end
end
