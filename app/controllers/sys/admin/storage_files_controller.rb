class Sys::Admin::StorageFilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_action :force_html_format

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
    return http_error(404) if @item.nil? || !@item.exists?
    return error_auth unless @item.readable?

    @parent = @item.parent
    return http_error(404) unless @parent.exists?
  end

  def index
    return if filter_actions

    @current = @item
    return http_error(404) unless @current.directory_entry?

    @items = @current.children
    _index @items
  end

  def show
    render :show, formats: [:html]
  end

  def download
    if @item.directory_entry?
      if (du_size = @item.du_size.to_i) > (max_size = Core.site.zip_download_max_size)
        helpers = ApplicationController.helpers
        redirect_to url_for(path: @item.path_from_site_root, do: :show),
                    notice: "ファイル合計容量（#{helpers.number_to_human_size(du_size)}）が制限値（#{helpers.number_to_human_size(max_size)}）を超えています。"
      else
        tmppath = @item.compress_to_tmpfile
        send_file(tmppath, filename: "#{@item.name}.zip",
                           content_type: Rack::Mime.mime_type('.zip'),
                           disposition: :attachment)
      end
    else
      send_data(@item.body, content_type: @item.mime_type,
                            disposition: :attachment)
    end
  end

  def create
    @current = @item

    if params[:create_directory]
      @item = Sys::Storage::Directory.new(base_dir: @current.path, name: params[:item][:new_directory])
      if @item.save
        flash[:notice] = 'ディレクトリを作成しました。'
        return redirect_to(path: @current.path_from_site_root)
      else
        flash.now[:notice] = 'ディレクトリの作成に失敗しました。'
      end
    elsif params[:create_file]
      @item = Sys::Storage::File.new(base_dir: @current.path, name: params[:item][:new_file])
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
    if (item_params = params[:item])
      if @item.file_entry?
        @item.name = item_params[:name]
        @item.body = item_params[:body] if item_params.key?(:body)
      elsif @item.directory_entry?
        @item.name = item_params[:name]
      end
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

  def filter_actions
    actions = { 'show' => :show, 'edit' => :edit, 'download' => :download,
                'POST' => :create, 'PATCH' => :update, 'DELETE' => :destroy }

    @do = params[:do].presence || 'index'

    if (action = actions[@do] || actions[request.request_method])
      public_send(action)
      return true
    end

    false
  end
end
