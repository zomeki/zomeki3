class Cms::Admin::Tool::ConvertImportsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    @item = ::Tool::ConvertImport.find(params[:id]) if params[:id].present?
    @items = ::Tool::ConvertImport.order(created_at: :desc).paginate(page: params[:page], per_page: 10)
  end

  def index
    @item = ::Tool::ConvertImport.new
    _index @items
  end

  def create
    site_filenames = []
    none_specified = false
    success = 0
    failed  = 0

    _params = import_params

    if _params[:site_filename].is_a?(Array)
      site_filenames = _params[:site_filename]
    else
      site_filenames = ['']
      none_specified = true
    end

    site_filenames.each do |f|
      next if f.blank? && site_filenames.size > 1
      _params[:site_filename] = f

      @item = ::Tool::ConvertImport.new(_params)
      if @item.creatable? && @item.save
        @item.import
        success += 1
      else
        failed += 1
      end
    end

    if success > 0
      comment = none_specified ? "" : "(成功：#{success}件、失敗：#{failed}件)";
      redirect_to url_for(:action => :index), :notice => "書き込み処理が終了しました。#{comment}"
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

  def filename_options
    filenames = ::Tool::ConvertImport.new(site_url: params[:site_url]).site_filename_options
    if filenames.blank?
      filenames = [['ファイルが見つかりませんでした。', '']]
    else
      filenames = [['', '']] + filenames
    end
    render text: ApplicationController.helpers.options_for_select(filenames), layout: false
  end

  private

  def import_params
    return {} unless params[:item]
    params.require(:item).permit(:site_url, :content_id, :overwrite, :keep_filename, :site_filename => [])
  end
end
