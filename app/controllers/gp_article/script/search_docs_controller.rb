class GpArticle::Script::SearchDocsController < Cms::Controller::Script::Publication
  def publish
    render plain: 'OK'
  end
end
