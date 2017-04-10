class Sys::Admin::StorageFilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_action :force_html_format
  before_action :filter_by_do_param

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)

    site_path = Rails.root.join("sites/#{format('%04d', Core.site.id)}").to_s
    @root_dirs =
      if Core.user.root?
        Dir.glob("#{site_path}/*").map { |path| [dir = File.basename(path), dir] }
      else
        [['public', 'public']]
      end

    params[:path] = 'public' if params[:path].blank?
    @root_dir = params[:path].split('/').first

    path = ::File.join(site_path, params[:path].to_s)

    @item = Sys::Storage::Entry.from_path(path)
    return http_error(404) unless @item.exists?
    return error_auth unless @item.readable?

    @parent = @item.parent
    return http_error(404) unless @parent.exists?
  end

  def index
    @current = @item
    return http_error(404) unless @current.directory_entry?

    @items = @current.children
    _index @items
  end

  def show
    render :show, formats: [:html]
  end

  def download
    send_data(@item.body, content_type: @item.mime_type, disposition: :attachment)
  end

  def create
    @current = @item

    if params[:create_directory]
      @item = Sys::Storage::Entry.new(base_dir: @current.path, name: params[:item][:new_directory],
                                      entry_type: :directory)
      if @item.save
        flash[:notice] = 'ディレクトリを作成しました。'
        return redirect_to(path: @current.path_from_site_root)
      else
        flash.now[:notice] = 'ディレクトリの作成に失敗しました。'
      end
    elsif params[:create_file]
      @item = Sys::Storage::Entry.new(base_dir: @current.path, name: params[:item][:new_file],
                                      entry_type: :file, body: '')
      if @item.save
        flash[:notice] = 'ファイルを作成しました。'
        return redirect_to(do: :show, path: @item.path_from_site_root)
      else
        flash.now[:notice] = 'ファイルの作成に失敗しました。'
      end
    elsif params[:upload_file]
      uploader = Sys::Storage::Uploader.new(@item)
      @results, @unzip_results = uploader.upload_files(params[:item][:new_upload],
                                                       overwrite: params.dig(:item, :upload_overwrite).present?,
                                                       unzip: !params.dig(:item, :open_zip).present?)
    end

    @items = @current.children
    render :index
  end

  def edit
    render :edit, formats: [:html]
  end

  def update
    if @item.file_entry?
      @item.body = params[:body]
    end

    if @item.save
      flash[:notice] = "更新処理が完了しました。"
      redirect_to(path: @parent.path_from_site_root)
    else
      flash.now[:notice] = "更新処理に失敗しました。"
      render :edit, formats: [:html]
    end
  end

  def destroy
    if @item.destroy
      flash[:notice] = "削除処理が完了しました。"
    else
      flash[:notice] = "削除処理に失敗しました。"
    end

    redirect_to(path: @parent.path_from_site_root)
  end

  private

  def force_html_format
    request.format = :html
  end

  def filter_by_do_param
    @do = params[:do].presence || 'index'
    case @do
    when 'show'
      show
    when 'edit'
      edit
    when 'update'
      update
    when 'destroy'
      destroy
    when 'download'
      download
    end
  end
end
