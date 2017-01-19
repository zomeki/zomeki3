class GpArticle::Script::SearchDocsController < Cms::Controller::Script::Publication
  def self.publishable?
    false
  end
end
