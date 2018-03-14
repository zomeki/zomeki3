class Cms::Admin::Tool::ConvertImportsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    @item = ::Tool::ConvertImport.find(params[:id]) if params[:id].present?
    @items = ::Tool::ConvertImport.select_without(:log)
                                  .where(content_id: Cms::Content.select(:id).where(site_id: Core.site.id))
                                  .order(created_at: :desc)
                                  .paginate(page: params[:page], per_page: 10)
  end

  def index
    @item = ::Tool::ConvertImport.new(import_params)
    _index @items
  end

  def create
    @item = ::Tool::ConvertImport.new(import_params)
    if @item.creatable? && @item.save
      @item.import
      redirect_to url_for(:action => :index), notice: "書き込み処理が終了しました。"
    else
      render :index
    end
  end

  def show
    _show @item
  end

  def destroy
    _destroy @item
  end

  def download(item)
    send_data item.log, type: 'text/plain', filename: "convert_imports_#{@item.id}.txt"
  end

  def filename_options
    filenames = ::Tool::ConvertImport.new(site_url: params[:site_url]).site_filename_options
    if filenames.blank?
      filenames = [['ファイルが見つかりませんでした。', '']]
    else
      filenames = [['', '']] + filenames
    end
    render html: ApplicationController.helpers.options_for_select(filenames), layout: false
  end

  private

  def import_params
    return {} unless params[:item]
    params.require(:item).permit(:site_url, :content_id, :creator_group_id, :overwrite, :keep_filename, :site_filename => [])
  end
end
