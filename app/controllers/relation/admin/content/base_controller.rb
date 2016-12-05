class Relation::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    Relation::Content::Doc
  end
end
