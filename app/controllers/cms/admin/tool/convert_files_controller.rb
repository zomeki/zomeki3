class Cms::Admin::Tool::ConvertFilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_action :filter_by_do_param

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)

    FileUtils.mkdir(::Tool::Convert::SITE_BASE_DIR) unless ::File.exist?(::Tool::Convert::SITE_BASE_DIR)
    @path = ::File.join(::Tool::Convert::SITE_BASE_DIR, params[:path].to_s).to_s
    @item = Sys::Storage::Entry.from_path(@path)
    return error_auth unless @item.path.start_with?(::Tool::Convert::SITE_BASE_DIR)
  end

  def index
    @items = @item.children
  end

  def show
    render :show
  end

  def destroy
    flash[:notice] = if @item.destroy
                       "削除処理が完了しました。"
                     else
                       "削除処理に失敗しました。"
                     end
    redirect_to path: @item.parent.relative_path_from(::Tool::Convert::SITE_BASE_DIR)
  end

  private

  def filter_by_do_param
    @do = params[:do].presence || 'index'
    case @do
    when 'show'
      show
    when 'destroy'
      destroy
    end
  end
end
