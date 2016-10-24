class Sys::Admin::Inline::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    simple_layout
    @parent = params[:parent]
    @tmp    = true if @parent.size == 32
  end

  def index
    item = 
      if @tmp
        Sys::File.where(tmp_id: @parent, parent_unid: nil)
      else
        Sys::File.where(tmp_id: nil, parent_unid: @parent)
      end
    @items = item.order(:name).paginate(page: params[:page], par_page: params[:limit])
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
    @item = Sys::File.new(params[:item])
    if @tmp
      @item.tmp_id      = @parent
    else
      @item.parent_unid = @parent
    end
    _create @item
  end

  def update
    @item = Sys::File.find(params[:id])
    @item.attributes  = params[:item]
    @item.skip_upload
    _update @item
  end

  def destroy
    @item = Sys::File.find(params[:id])
    _destroy @item
  end

  def download
    item = 
      if @tmp
        Sys::File.where(tmp_id: @parent, parent_unid: nil)
      else
        Sys::File.where(tmp_id: nil, parent_unid: @parent)
      end
    @file =
      if params[:id]
        item.where(id: params[:id]).first
      elsif params[:name] && params[:format]
        item.where(name: "#{params[:name]}.#{params[:format]}").first
      end
    return http_error(404) unless @file

    send_file @file.upload_path, type: @file.mime_type, filename: @file.name, disposition: 'inline'
  end
end
