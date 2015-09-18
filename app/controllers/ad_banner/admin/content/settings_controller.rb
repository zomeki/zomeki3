# encoding: utf-8
class AdBanner::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = AdBanner::Content::Banner.find(params[:content])
    return error_auth unless @content.editable?
  end

  def index
    @items = AdBanner::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = AdBanner::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def edit
    @item = AdBanner::Content::Setting.config(@content, params[:id])
    @item.value = YAML.load(@item.value.presence || '[]') if @item.form_type.in?([:check_boxes, :multiple_select])
    _show @item
  end

  def update
    @item = AdBanner::Content::Setting.config(@content, params[:id])
    value = params[:item][:value]
    if @item.form_type.in?([:check_boxes, :multiple_select])
      @item.value = YAML.dump(case value
                              when Hash; value.keys
                              when Array; value
                              else []
                              end)
    else
      @item.value = value
    end

    _update(@item)
  end
end
