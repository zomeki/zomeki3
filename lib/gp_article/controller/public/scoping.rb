module GpArticle::Controller::Public::Scoping
  extend ActiveSupport::Concern

  included do
    around_action :set_gp_article_mobile_scoping
    around_action :set_gp_article_public_scoping
  end

  private

  def set_gp_article_mobile_scoping
    GpArticle::Doc.mobile(request.mobile?).scoping { yield }
  end

  def set_gp_article_public_scoping
    if Core.mode == 'preview' && Page.preview_at
      Cms::PreviewItemsFinder.new(GpArticle::Doc, Core.user).search(Page.preview_at).scoping { yield }
    else
      GpArticle::Doc.public_state.scoping { yield }
    end
  end
end
