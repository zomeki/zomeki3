class GpCalendar::Admin::EventsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = GpCalendar::Content::Event.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to url_for(action: :index) if params[:reset_criteria]
#    return redirect_to(request.env['REQUEST_PATH']) if params[:reset_criteria]
  end

  def index
    @items = GpCalendar::EventsFinder.new(@content.events)
                                     .search(event_criteria)
                                     .paginate(page: params[:page], per_page: params[:limit])
                                     .preload(:periods)

    _index @items
  end

  def show
    @item = @content.events.find(params[:id])
    _show @item
  end

  def new
    @item = @content.events.build
  end

  def create
    @item = @content.events.build(event_params)
    _create(@item) do
      set_file
    end
  end

  def update
    @item = @content.events.find(params[:id])
    @item.attributes = event_params
    _update(@item) do
      set_file
    end
  end

  def destroy
    @item = @content.events.find(params[:id])
    _destroy(@item)
  end

  def file_content
    item = @content.events.find(params[:id])
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
      file.allowed_types = %w(gif jpg png)
      file.save
    end
  end

  def event_criteria
    criteria = params[:criteria] || {}

    [:sort_key, :sort_order].each do |key|
      criteria[key] = params[key] if params[key]
    end

    criteria
  end

  def event_params
    params.require(:item).permit(
      :description, :ended_on, :href, :started_on, :state, :target, :title, :note, :will_sync, :in_tmp_id,
      :creator_attributes => [:id, :group_id, :user_id],
      :periods_attributes => [:id, :started_on, :ended_on]
    ).tap do |permitted|
      [:in_category_ids].each do |key|
        permitted[key] = params[:item][key].to_unsafe_h if params[:item][key]
      end
    end
  end
end
