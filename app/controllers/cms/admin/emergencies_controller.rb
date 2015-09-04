# encoding: utf-8
class Cms::Admin::EmergenciesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)

    @parent   = Core.site.root_node
    @node     = @parent.children.where(name: 'index.html').first
    @node   ||= @parent.children.where(name: 'index.htm').first
  end

  def index
    @items = Core.site.emergency_layout_settings.order(:sort_no)
  end

  def show
    @item = Core.site.emergency_layout_settings.find(params[:id])
    @item.value = @item.value.to_i if @item.value

    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Core.site.emergency_layout_settings.build(
      :sort_no => 0
    )
  end

  def create
    @item = Core.site.emergency_layout_settings.build(emergency_layout_params)
    _create @item
  end

  def update
    @item = Core.site.emergency_layout_settings.find(params[:id])
    @item.attributes = emergency_layout_params
    _update @item
  end

  def destroy
    @item = Core.site.emergency_layout_settings.find(params[:id])
    _destroy @item
  end

  def change
    @item = Core.site.emergency_layout_settings.find(params[:id])

    if @item.value.blank?
      @item.errors.add_to_base "レイアウトが登録されていません。"
    end
    unless layout = Cms::Layout.find_by(id: @item.value)
      @item.errors.add_to_base "レイアウトが見つかりません。"
    end
    unless @node
      @item.errors.add_to_base "トップページが見つかりません。"
    end

    if @item.errors.size == 0
      @node.layout_id = @item.value
      @node.save(:validate => false)
    end

    if @item.errors.size == 0
      flash[:notice] = '反映処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to url_for(:action => :index) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = '反映処理に失敗しました。'
      respond_to do |format|
        format.html { redirect_to url_for(:action => :index) }
        format.xml  { render(:xml => @item.errors, :status => :unprocessable_entity) }
      end
    end
  end

  private

  def emergency_layout_params
    params.require(:item).permit(:sort_no, :value)
  end
end
