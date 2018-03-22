module GpArticle::Controller::Public::Scoping
  extend ActiveSupport::Concern

  included do
    around_action :set_gp_article_docs_mobile_scoping
  end

  private

  def set_gp_article_docs_mobile_scoping
    GpArticle::Doc.mobile(request.mobile?).scoping { yield }
  end
end
