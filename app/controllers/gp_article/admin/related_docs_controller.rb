require 'csv'
class GpArticle::Admin::RelatedDocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  layout :select_layout

  def pre_dispatch
    return http_error(404) unless @content = GpArticle::Content::Doc.find_by(id: params[:content])
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
