class Cms::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def model
    Cms::ContentSetting
  end

  def content_model
    model.reflect_on_association(:content).klass
  end

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = content_model.find(params[:content])
    return error_auth unless @content.editable?
  end

  def index
    @items = model.configs(@content)
    _index @items
  end

  def show
    @item = model.config(@content, params[:id])
    _show @item
  end

  def update
    @item = model.config(@content, params[:id])
    @item.value = params[:item][:value]
    @item.extra_values = params[:item][:extra_values] if params[:item][:extra_values]
    _update @item
  end
end
