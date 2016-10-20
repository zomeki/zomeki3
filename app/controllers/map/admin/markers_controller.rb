class Map::Admin::MarkersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Map::Content::Marker.find_by(id: params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @content.markers.paginate(page: params[:page], per_page: 50)
    _index @items
  end

  def show
    @item = @content.markers.find(params[:id])
    _show @item
  end

  def new
    @item = @content.markers.build
  end

  def create
    @item = @content.markers.build(marker_params)
    _create(@item) do
      set_categories
      set_file
    end
  end

  def update
    @item = @content.markers.find(params[:id])
    @item.attributes = marker_params
    _update(@item) do
      set_categories
      set_file
    end
  end

  def destroy
    @item = @content.markers.find(params[:id])
    _destroy @item
  end

  def file_content
    item = @content.markers.find(params[:id])
    return http_error(404) if item.files.empty?
    file = item.files.first
    mt = file.mime_type.presence || Rack::Mime.mime_type(File.extname(file.name))
    type, disposition = (mt =~ %r!^image/|^application/pdf$! ? [mt, 'inline'] : [mt, 'attachment'])
    disposition = 'attachment' if request.env['HTTP_USER_AGENT'] =~ /Android/
    send_file file.upload_path, :type => type, :filename => file.name, :disposition => disposition
  end

  private

  def set_categories
    category_ids = if params[:categories]
                     params[:categories].values.flatten.reject{|c| c.blank? }.uniq
                   else
                     []
                   end
    @item.category_ids = category_ids
  end

  def set_file
    if params[:delete_file]
      @item.files.each {|f| f.destroy } unless @item.files.empty?
    end
    if (param_file = params[:file])
      @item.files.each {|f| f.destroy } unless @item.files.empty?
      filename = "image#{File.extname(param_file.original_filename)}"
      file = @item.files.build(file: param_file, name: filename, title: filename)
      file.allowed_type = 'gif,jpg,png'
      file.save
    end
  end

  def marker_params
    params.require(:item).permit(:latitude, :longitude, :state, :title, :window_text)
  end
end
