class Sys::Admin::StorageFilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  before_action :force_html_format
  before_action :validate_path

  @root  = nil
  @roots = []
  @navi  = []

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)

    sites   = Cms::Site.order(:id).all
    @roots  = [["sites", "sites"]]
  end

  def validate_path
    return error_auth if !Core.user.root? && params[:path] =~ /^(public|upload)/

    @path = ::File.join(Rails.root.to_s, params[:path].to_s)
    #return http_error(404) if params[:path] && !::Storage.exists?(@path)

    return error_auth if params[:path] =~ /^sites\/\d{4}/ && params[:path] !~ /^#{::File.join('sites', format('%04d', Core.site.id))}/


    @dir = params[:path]
    @roots.each do |dir, path|
      if @dir.to_s =~ /^#{Regexp.escape(dir)}(\/|$)/
        @root = dir
        break
      end
    end

    if !@root
      @root = @roots.first[1]
      @path = ::File.join(@path, @root)
      @dir  = @root
    end

    @navi = []
    dirs = @dir.split(/\//)
    dirs.each_with_index do |n, idx|
      next if idx == 0
      @navi << [n, dirs.slice(0, idx + 1).join("/")]
    end

    @do          = params[:do].blank? ? nil : params[:do]
    @is_dir      = ::Storage.directory?(@path)
    @is_file     = ::Storage.file?(@path)
    @current_uri = sys_storage_files_path(@dir).gsub(/\?.*/, '')
    @parent_uri  = sys_storage_files_path(:path => ::File.dirname(@dir)).gsub(/\?.*/, '')
  end

  def index
    if @do == "show"
      return http_error(404) if !::Storage.exists?(@path)
      return show_dir if @is_dir
      return show_file if @is_file
    elsif @do == "download"
      return send_data(::Storage.read(@path), :content_type => ::Storage.mime_type(@path), :disposition => :attachment)
    elsif @do == "edit"
      return edit_file
    elsif @do == "rename"
      return rename
    elsif @do == "destroy"
      return destroy
    elsif @is_file
      return show_file
    end

    @dirs  = []
    @files = []
    files  = ::Storage.entries(@path)
    files.each { |name|
      next if @path =~ /^#{Rails.root.join('sites')}/ && "#{@path}/#{name}" !~ /^#{Rails.root.join('sites', format('%04d', Core.site.id))}/
      @dirs << name if ::Storage.directory?("#{@path}/#{name}")
    }
    files.each {|name| @files << name if ::Storage.file?("#{@path}/#{name}")}

    @items = @dirs.sort + @files.sort

    _index @items
  end

  def show_dir
    @item = {
      :name      => ::File.basename(@path),
    }
    render :show_dir
  end

  def show_file
    body = nil
    if body = ::Storage.read(@path)
      body = NKF.nkf('-w', body) if body.is_a?(String)
      body = body.force_encoding("utf-8") if body.respond_to?(:force_encoding)
    end

    @item = {
      :name      => ::File.basename(@path),
      :mtime     => ::Storage.mtime(@path),
      :size      => ::Storage.kb_size(@path),
      :mime_type => ::Storage.mime_type(@path),
      :body      => body,
    }
    render :show_file, formats: [:html]
  end

  def edit_file
    body = nil
    if body = ::Storage.read(@path)
      body = NKF.nkf('-w', body) if body.is_a?(String)
      body = body.force_encoding("utf-8") if body.respond_to?(:force_encoding)
    end

    @item = {
      :name      => ::File.basename(@path),
      :mtime     => ::Storage.mtime(@path),
      :size      => ::Storage.kb_size(@path),
      :mime_type => ::Storage.mime_type(@path),
      :body      => body,
    }
    render :edit_file, formats: [:html]
  end

  def new
    exit
  end

  def create
    return update if params[:do] == "update"

    if params[:create_directory]
      if name = validate_name(params[:item][:new_directory])
        if ::Storage.exists?("#{@path}/#{name}")
          flash[:notice] = "ディレクトリは既に存在します。"
        elsif name =~ /^_/
          flash[:notice] = "先頭に「_」を含むディレクトリは作成できません。"
        else
          ::Storage.mkdir("#{@path}/#{name}")
          flash[:notice] = "ディレクトリを作成しました。"
        end
        return redirect_to(@current_uri)
      else
        flash[:notice] = "ディレクトリ名は半角英数字で入力してください。"
      end

    elsif params[:create_file]
      if name = validate_name(params[:item][:new_file])
        if ::Storage.exists?("#{@path}/#{name}")
          flash[:notice] = "ファイルは既に存在します。"
        else
          ::Storage.write("#{@path}/#{name}", "")
          flash[:notice] = "ファイルを作成しました。"
        end
        return redirect_to("#{@current_uri}/#{name}?do=show")
      else
        if @invalid_filename
          flash[:notice] = "ファイル名は半角英数字で入力してください。"
        else
          flash[:notice] = "許可されていないファイルです。（#{Core.site.setting_site_allowed_attachment_type}）"
        end
      end
    elsif params[:upload_file] && file = params[:item][:new_upload]

      if name = validate_name(file.original_filename)
        ::Storage.binwrite("#{@path}/#{name}", file.read)
        flash[:notice] = "アップロードが完了しました。"
        return redirect_to(@current_uri)
      else
        if @invalid_filename
          flash[:notice] = "ファイル名は半角英数字で入力してください。"
        else
          flash[:notice] = "許可されていないファイルです。（#{Core.site.setting_site_allowed_attachment_type}）"
        end
      end
    end

    redirect_to @current_uri
  end

  def update
    if ::Storage.write(@path, params[:body])
      flash[:notice] = "更新処理が完了しました。"
    else
      flash[:notice] = "更新処理に失敗しました。"
    end

    return redirect_to(@parent_uri)
  end

  def destroy
    if ::Storage.rm_rf(@path)
      flash[:notice] = "削除処理が完了しました。"
    else
      flash[:notice] = "削除処理に失敗しました。"
    end

    redirect_to @parent_uri
  end

protected

  def validate_name(name)
    if name.to_s !~ /^[0-9A-Za-z@\.\-\_]+$/
      @invalid_filename = true
      return nil
    end

    if Core.site.setting_site_allowed_attachment_type.present?
      types = {}
      Core.site.setting_site_allowed_attachment_type.to_s.split(/ *, */).each do |m|
        m = ".#{m.gsub(/ /, '').downcase}"
        types[m] = true if !m.blank?
      end

      if name.present?
        ext = ::File.extname(name.to_s).downcase
        if types[ext] != true
          return nil
        end
      end
    end
    return name
  end

  def force_html_format
    request.format = :html
  end
end
