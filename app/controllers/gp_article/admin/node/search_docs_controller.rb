class GpArticle::Admin::Node::SearchDocsController < Cms::Admin::Node::BaseController
  def model
    Cms::Node::Directory
  end
end
