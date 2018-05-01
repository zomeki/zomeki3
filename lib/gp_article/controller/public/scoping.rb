module GpArticle::Controller::Public::Scoping
  extend ActiveSupport::Concern

  included do
    prepend_around_action :set_gp_article_mobile_scoping
    prepend_around_action :set_gp_article_public_scoping
  end

  private

  def set_gp_article_mobile_scoping
    GpArticle::Doc.mobile(request.mobile?).scoping { yield }
  end

  def set_gp_article_public_scoping
    if Core.preview_mode? && Page.preview_at
      Cms::PreviewItemsFinder.new(GpArticle::Doc, Core.user).search(Page.preview_at).scoping { yield }
    else
      GpArticle::Doc.public_state.scoping { yield }
    end
  end
end
