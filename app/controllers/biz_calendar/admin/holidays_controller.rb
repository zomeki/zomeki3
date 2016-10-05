class BizCalendar::Admin::HolidaysController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = BizCalendar::Content::Place.find(params[:content])
    @place = @content.places.find(params[:place_id])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @items = @place.holidays.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    @item = @place.holidays.find(params[:id])
    _show @item
  end

  def new
    @item = @place.holidays.build
  end

  def create
    @item = @place.holidays.build(holiday_params)
    _create @item
  end

  def update
    @item = @place.holidays.find(params[:id])
    @item.attributes = holiday_params
    _update @item
  end

  def destroy
    @item = @place.holidays.find(params[:id])
    _destroy @item
  end

  private

  def holiday_params
    params.require(:item).permit(:state, :type_id, :holiday_start_date, :holiday_end_date, :repeat_type,
      :repeat_interval, :repeat_criterion, :start_date, :end_type, :end_times, :end_date,
      :repeat_week => [:_, :mon, :tue, :wed, :thurs, :fri, :sat, :sun],
      :creator_attributes => [:id, :group_id, :user_id])
  end
end
