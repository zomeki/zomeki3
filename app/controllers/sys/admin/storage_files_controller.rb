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

    @upload_maxsize = Core.site.try(:setting_site_file_upload_max_size) || 5
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
    @is_text_file = @item[:mime_type].blank? || @item[:mime_type] =~ /(text|javascript)/i

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
      if name = validate_dir_name(params[:item][:new_directory])
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

    elsif params[:upload_file] && files = params[:item][:new_upload]
      if session[:prev_authenticity_token] == params[:authenticity_token]
        return redirect_to(@current_uri)
      end
      session[:prev_authenticity_token] = params[:authenticity_token]

      notice = ''
      errors  = []
      unzip_results = []
      success = 0
      @overwrite = params[:item][:upload_overwrite] ? true : false
      @open_zip  = params[:item][:open_zip] ? false : true
      
      files.each do |file|
        if filesize_error = validate_filesize(file.original_filename, file.size)
          errors << {name: file.original_filename, msg: filesize_error}
        elsif @open_zip && file.original_filename =~ /^.+\.zip$/
          begin
            res = unzip(file, @overwrite)
          rescue => e
            res = [{ name: file.original_filename, msg: "ZIPファイルの解凍に失敗しました。(#{e})", status: 'NG' }]
          end
          unzip_results << {name: file.original_filename, msg: "ZIPファイルを展開してアップロードします。", res: res}
        elsif name = validate_name(file.original_filename)
          if !@overwrite && ::Storage.exists?("#{@path}/#{name}")
            errors << {name: file.original_filename, msg: "ファイルは既に存在します。"}
          else
            ::Storage.binwrite("#{@path}/#{name}", file.read)
            success = success + 1
          end
        else
          if @invalid_filename
            errors << {name: file.original_filename, msg: "ファイル名は半角英数字で入力してください。"}
          else
            errors << {name: file.original_filename, msg: "許可されていないファイルです。（#{Core.site.setting_site_allowed_attachment_type}）"}
          end
        end
      end
      
      @notice = "#{success}件のファイルアップロード処理が完了しました。" if success > 0
      @errors = errors
      @unzip_results = unzip_results
      
      @dirs  = []
      @files = []
      files  = ::Storage.entries(@path)
      files.each { |filename|
        next if @path =~ /^#{Rails.root.join('sites')}/ && "#{@path}/#{filename}" !~ /^#{Rails.root.join('sites', format('%04d', Core.site.id))}/
        @dirs << filename if ::Storage.directory?("#{@path}/#{filename}")
      }
      files.each {|filename| @files << filename if ::Storage.file?("#{@path}/#{filename}")}
      
      @items = @dirs.sort + @files.sort
      return render :index

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

  def validate_dir_name(name)
    name.to_s =~ /^[0-9A-Za-z@\.\-\_]+$/ ? name : nil
  end

  def validate_name(name)
    @invalid_filename = false
    if name.to_s !~ /^[0-9A-Za-z@\.\-\_]+$/
      @invalid_filename = true
      return nil
    end
    
    return nil unless validate_mime_type(name)

    return name
  end

  def validate_mime_type(name)
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

  def validate_filesize(name, size)
    maxsize = @upload_maxsize
    if Core.site
      ext = ::File.extname(name.to_s).downcase
      if _maxsize = Core.site.get_upload_max_size(ext)
        maxsize = _maxsize
      end
    end
    
    if size > maxsize.to_i  * (1024**2)
      return "容量制限を超えています。＜#{maxsize}MB＞"
    end

    return nil
  end

  def force_html_format
    request.format = :html
  end

  def unzip(file, overwrite = false)
    require 'zip'
    
    outpath = @path
    
    ret = []

    Zip::InputStream.open(file.tempfile, 0) do |input|
      while (entry = input.get_next_entry)
        entry_name = entry.name.to_utf8
        save_path = ::File.join(@path, entry_name)
        save_dir  = ::File.dirname(save_path)

        if save_dir !~ /^[0-9A-Za-z@\.\-\_\/]+$/
          ret << {name: entry_name, msg: "ディレクトリ名は半角英数字で入力してください。", status: 'NG'}
          next
        end

        if entry.name_is_directory?
          ::Storage.mkdir_p("#{save_dir}") unless ::Storage.exists?("#{save_dir}")
        else
          if entry.name !~ /^[0-9A-Za-z@\.\-\_\/]+$/
            ret << {name: entry_name, msg: "ファイル名は半角英数字で入力してください。", status: 'NG'}
            next
          end
          unless name = validate_mime_type(entry.name)
            ret << {name: entry_name, msg: "許可されていないファイルです。（#{Core.site.setting_site_allowed_attachment_type}）", status: 'NG'}
            next
          end
          if !overwrite && ::Storage.exists?(save_path)
            ret << {name: entry_name, msg: "ファイルは既に存在します。", status: 'NG'}
            next
          end
          ::Storage.mkdir_p("#{save_dir}") unless ::Storage.exists?("#{save_dir}")
          entry.get_input_stream do |stream|
            ::Storage.binwrite(save_path, stream.read)
          end

          ret << {name: entry_name, msg: "アップロード完了", status: 'OK'}
        end
      end
    end

    return ret
  end
end
