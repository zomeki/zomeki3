class Relation::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Relation::Content::Doc.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @content.docs.paginate(page: params[:page], per_page: 50)
    _index @items
  end
end
