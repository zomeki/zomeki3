class Sys::Admin::Inline::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  layout 'admin/files'

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    @content = @content.downcast

    if params[:parent] =~ /-/
      parent_type, parent_id = params[:parent].split('-')
      @parent = parent_type.constantize.find(parent_id)
    else
      @tmp_id = params[:parent]
    end
  end

  def index
    @item = Sys::File.new
    @items = load_index_items
    _index @items
  end

  def show
    @item = Sys::File.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Sys::File.new
  end

  def create
    @item = Sys::File.new(site_id: Core.site.id)

    files = params[:files].presence || []
    names = params[:names].presence || []
    titles = params[:titles].presence || []
    alts = params[:alts].presence || []
    success = failure = 0

    files.each_with_index do |file, i|
      item = Sys::File.new(file: files[i], name: names[i], title: titles[i], alt_text: alts[i])
      item.site_id = Core.site.id
      if @tmp_id
        item.tmp_id = @tmp_id
      else
        item.file_attachable = @parent
      end

      if (duplicated = item.duplicated)
        item = duplicated
        item.attributes = { file: files[i], name: names[i], title: titles[i], alt_text: alts[i] }
      end

      item.image_resize = params[:image_resize] if params[:image_resize].present?
      item.allowed_type = get_allowed_type
      item.use_thumbnail(get_thumbnail_size)

      if item.creatable? && item.save
        success += 1
      else
        failure += 1
        item.errors.full_messages.each { |msg| @item.errors.add(:base, "#{item.name}: #{msg}") }
      end
    end

    flash.now[:notice] = "#{success}件の登録処理が完了しました。（#{I18n.l Time.now}）" if success > 0
    flash.now[:alert]  = "#{failure}件の登録処理に失敗しました。" if failure > 0

    @items = load_index_items
    render :index
  end

  def update
    @item = Sys::File.find(params[:id])
    @item.attributes = file_params
    @item.allowed_type = get_allowed_type
    @item.skip_upload
    _update @item
  end

  def destroy
    @item = Sys::File.find(params[:id])
    _destroy @item
  end

  def content
    params[:name] = File.basename(params[:path])
    params[:type] = :thumb if params[:path] =~ /(\/|^)thumb\//
    download
  end

  def download
    @item = @tmp_id ?
      Sys::File.where(tmp_id: @tmp_id) :
      Sys::File.where(file_attachable: @parent)

    @item = params[:id] ?
      @item.find(params[:id]) :
      @item.find_by!(name: "#{params[:name]}.#{params[:format]}")
    return error_auth unless @item.readable?

    if params[:convert] == 'csv:table' && @item.csv?
      render plain: convert_to_csv(@item)
    else
      send_file @item.upload_path(type: params[:type]), filename: @item.name
    end
  end

  def crop
    @item = Sys::File.find(params[:id])
    return error_auth unless @item.editable?

    if request.post?
      if params[:x].to_i != 0 || params[:y].to_i != 0
        @item.use_thumbnail(get_thumbnail_size)
        if @item.crop(params[:x].to_i, params[:y].to_i, params[:w].to_i, params[:h].to_i)
          flash[:notice] = "トリミングしました。"
        else
          flash[:alert]  = "トリミングに失敗しました。"
        end
      end
      redirect_to action: :index
    end
  end

  def view
    @items = load_index_items
    _index @items
  end

  private

  def file_params
    params.require(:item).permit(:file, :name, :title)
  end

  def get_allowed_type
    if @content.respond_to?(:allowed_attachment_type)
      @content.allowed_attachment_type
    else
      params[:allowed_type]
    end 
  end

  def get_thumbnail_size
    if @content.respond_to?(:attachment_thumbnail_size)
      @content.attachment_thumbnail_size
    else
      params[:attachment_thumbnail_size]
    end
  end

  def load_index_items
    items = @tmp_id ?
      Sys::File.where(tmp_id: @tmp_id) :
      Sys::File.where(file_attachable: @parent)
    items.order(:name).paginate(page: params[:page], per_page: params[:limit])
  end

  def convert_to_csv(item)
    require 'nkf'
    csv = NKF.nkf('-w', File.read(item.upload_path))
    Util::String::CsvToHtml.convert(csv)
  end
end
