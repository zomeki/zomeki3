class BizCalendar::Admin::PlacesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
   @content = BizCalendar::Content::Place.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = BizCalendar::Place.where(content_id: @content.id).search_with_params(params)
      .order(sort_no: :asc, updated_at: :desc, id: :desc)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = BizCalendar::Place.find(params[:id])
    #return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = @content.places.build
  end

  def create
    @item = @content.places.build(place_params)
    _create(@item)
  end

  def update
    @item = @content.places.find(params[:id])
    @item.attributes = place_params
    _update(@item)
  end

  def destroy
    @item = @content.places.find(params[:id])
    _destroy @item
  end

  private

  def place_params
    params.require(:item).permit(:state, :url, :title, :summary, :description,
      :business_hours_state, :business_hours_title, :business_holiday_state, :business_holiday_title, :sort_no,
      :in_creator => [:group_id, :user_id])
  end
end
