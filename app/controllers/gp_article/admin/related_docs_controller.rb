class GpArticle::Admin::RelatedDocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = GpArticle::Content::Doc.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def show
    @item = GpArticle::Doc.find_by(id: params[:id])
    @doc = {
      id: @item.id, title: @item.title, full_uri: @item.state_public? ? @item.public_full_uri : nil,
      name: @item.name, content: @item.content_id,
      updated: @item.updated_at.strftime('%Y/%m/%d %H:%M'), status: @item.status.name,
      user: @item.creator.user.try(:name), group: @item.creator.group.try(:name)
    }
    render xml: @doc
  end
end
