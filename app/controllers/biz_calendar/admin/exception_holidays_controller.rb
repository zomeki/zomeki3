class BizCalendar::Admin::ExceptionHolidaysController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = BizCalendar::Content::Place.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @place = @content.places.find(params[:place_id])
  end

  def index
    @items = @place.exception_holidays.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    @item = @place.exception_holidays.find(params[:id])
    _show @item
  end

  def new
    @item = @place.exception_holidays.build
  end

  def create
    @item = @place.exception_holidays.build(exception_holiday_params)
    _create @item
  end

  def update
    @item = @place.exception_holidays.find(params[:id])
    @item.attributes = exception_holiday_params
    _update @item
  end

  def destroy
    @item = @place.exception_holidays.find(params[:id])
    _destroy @item
  end

  private

  def exception_holiday_params
    params.require(:item).permit(:state, :start_date, :end_date, :creator_attributes => [:id, :group_id, :user_id])
  end
end
