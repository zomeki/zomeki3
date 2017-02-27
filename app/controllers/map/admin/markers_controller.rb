class Map::Admin::MarkersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Map::Content::Marker.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
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
      set_file
    end
  end

  def update
    @item = @content.markers.find(params[:id])
    @item.attributes = marker_params
    _update(@item) do
      set_file
    end
  end

  def destroy
    @item = @content.markers.find(params[:id])
    _destroy @item
  end

  def file_content
    item = @content.markers.find(params[:id])
    file = item.files.first
    return http_error(404) unless file

    send_file file.upload_path, filename: file.name
  end

  private

  def set_file
    if params[:delete_file]
      @item.files.each {|f| f.destroy } unless @item.files.empty?
    end
    if (param_file = params[:file])
      @item.files.each {|f| f.destroy } unless @item.files.empty?
      filename = "image#{File.extname(param_file.original_filename)}"
      file = @item.files.build(file: param_file, name: filename, title: filename, site_id: Core.site.id)
      file.allowed_type = 'gif,jpg,png'
      file.save
    end
  end

  def marker_params
    params.require(:item).permit(:latitude, :longitude, :state, :title, :window_text).tap do |permitted|
      [:in_category_ids].each do |key|
        permitted[key] = params[:item][key].to_unsafe_h if params[:item][key]
      end
    end
  end
end
