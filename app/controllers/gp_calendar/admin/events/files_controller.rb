class GpCalendar::Admin::Events::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  layout 'admin/files'

  def pre_dispatch
    return http_error(404) unless @content = GpCalendar::Content::Event.find_by(id: params[:content])

    if (@event_id = params[:event_id]) =~ /^[0-9a-z]{32}$/
      @tmp_id = @event_id
    else
      @event = @content.events.find(@event_id)
    end
  end

  def index
    @item = Sys::File.new(site_id: Core.site.id)
    @items = Sys::File.where(tmp_id: @tmp_id).order(:name)
    @items = @items.where(file_attachable: @event) if @event
    @items = @items.paginate(page: params[:page], per_page: 20)
    _index @items
  end

  def show
    @item = Sys::File.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def create
    @item = Sys::File.new(file_params)
    @item.site_id = Core.site.id
    @item.tmp_id = @tmp_id
    @item.file_attachable = @event if @event

    if (duplicated = @item.duplicated)
      @item = duplicated
      @item.attributes = file_params
    end

    @item.allowed_type = 'gif,jpg,png'
    @item.image_resize = params[:image_resize]
    _create @item
  end

  def update
    @item = Sys::File.find(params[:id])
    @item.attributes = file_params
    @item.allowed_type = 'gif,jpg,png'
    @item.image_resize = params[:image_resize]
    @item.skip_upload
    _update @item
  end

  def destroy
    @item = Sys::File.find(params[:id])
    _destroy @item
  end

  def content
    file = Sys::File.where(tmp_id: @tmp_id)
    file = file.where(file_attachable: @event) if @event
    if (file = file.where(name: "#{params[:basename]}.#{params[:extname]}").first)
      mt = Rack::Mime.mime_type(".#{params[:extname]}")
      type, disposition = (mt =~ %r!^image/|^application/pdf$! ? [mt, 'inline'] : [mt, 'attachment'])
      disposition = 'attachment' if request.env['HTTP_USER_AGENT'] =~ /Android/
      send_file file.upload_path, :type => type, :filename => file.name, :disposition => disposition
    else
      http_error(404)
    end
  end

  private

  def file_params
    params.require(:item).permit(:file, :name, :title)
  end
end
