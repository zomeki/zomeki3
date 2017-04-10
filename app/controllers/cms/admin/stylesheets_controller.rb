class Cms::Admin::StylesheetsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_action :force_html_format
  before_action :filter_by_do_param

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)

    themes_path = Rails.root.join("sites/#{format('%04d', Core.site.id)}/public/_themes").to_s
    params[:path] = '' if params[:path].blank?
    @root_dir = params[:path].split('/').first

    path = ::File.join(themes_path, params[:path].to_s)

    @item = Cms::Storage::Stylesheet.from_path(path)
    return http_error(404) unless @item.exists?

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
    return error_auth unless @item.creatable?
    @current = @item

    if params[:create_directory]
      @item = Cms::Storage::Stylesheet.new(base_dir: @current.path, name: params[:item][:new_directory],
                                           entry_type: :directory)
      if @item.save
        flash[:notice] = 'ディレクトリを作成しました。'
        return redirect_to(path: @current.path_from_themes_root)
      else
        flash.now[:notice] = 'ディレクトリの作成に失敗しました。'
      end
    elsif params[:create_file]
      @item = Cms::Storage::Stylesheet.new(base_dir: @current.path, name: params[:item][:new_file],
                                           entry_type: :file,  body: '')
      if @item.save
        flash[:notice] = 'ファイルを作成しました。'
        return redirect_to(do: :show, path: @item.path_from_themes_root)
      else
        flash.now[:notice] = 'ファイルの作成に失敗しました。'
      end
    elsif params[:upload_file]
      uploader = Sys::Storage::Uploader.new(@item)
      @results, @unzip_results = uploader.upload_files(params[:item][:new_upload],
                                                       overwrite: false,
                                                       unzip: false)
    end

    @items = @current.children
    render :index
  end

  def edit
    return error_auth unless @item.editable?
    render :edit, formats: [:html]
  end

  def update
    return error_auth unless @item.editable?

    if @item.file_entry?
      @item.name = params[:item][:name]
      @item.body = params[:item][:body]
    elsif @item.directory_entry?
      @item.concept_id = params[:item][:concept_id]
      @item.name = params[:item][:name]
    end

    if @item.save
      flash[:notice] = "更新処理が完了しました。"
      redirect_to(path: @parent.path_from_themes_root)
    else
      flash.now[:notice] = "更新処理に失敗しました。"
      render :edit, formats: [:html]
    end
  end

  def move
    return error_auth unless @item.editable?
    return render :move if request.get?

    @item.base_dir = ::File.join(@item.themes_root_path, params[:item][:base_dir])
    @item.name = params[:item][:name]
    if @item.editable? && @item.save
      flash[:notice] = "更新処理が完了しました。"
      redirect_to(path: @parent.path_from_themes_root)
    else
      flash[:notice] = "更新処理に失敗しました。"
      render :move, formats: [:html]
    end
  end

  def destroy
    return error_auth unless @item.deletable?

    if @item.destroy
      flash[:notice] = "削除処理が完了しました。"
    else
      flash[:notice] = "削除処理に失敗しました。"
    end

    redirect_to(path: @parent.path_from_themes_root)
  end

  private

  def force_html_format
    request.format = :html
  end

  def filter_by_do_param
    @do = request.post? ? 'create' : params[:do].presence || 'index'
    case @do
    when 'show'
      show
    when 'create'
      create
    when 'edit'
      edit
    when 'update'
      update
    when 'destroy'
      destroy
    when 'move'
      move
    when 'download'
      download
    end
  end
end
