class GpCalendar::Admin::HolidaysController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = GpCalendar::Content::Event.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    @items = @content.holidays.order("repeat desc, COALESCE(TO_CHAR(date,'YYYYMMDD'), '00000000')")
      .paginate(page: params[:page], per_page: 50)
    _index @items
  end

  def show
    @item = @content.holidays.find(params[:id])
    _show @item
  end

  def new
    @item = @content.holidays.build
  end

  def create
    @item = @content.holidays.build(holiday_params)
    @item.date = parse_date(holiday_params[:date], (holiday_params[:repeat]=='1' ? '' : '%Y年') + '%m月%d日')
    _create(@item) do
    end
  end

  def update
    @item = @content.holidays.find(params[:id])
    @item.attributes = holiday_params
    @item.date = parse_date(holiday_params[:date], (holiday_params[:repeat]=='1' ? '' : '%Y年') + '%m月%d日')
    _update(@item) do
    end
  end

  def destroy
    @item = @content.holidays.find(params[:id])
    _destroy(@item) do
    end
  end

  private

  def holiday_params
    params.require(:item).permit(
      :date, :description, :kind, :repeat, :state, :title,
      :creator_attributes => [:id, :group_id, :user_id]
    )
  end
end
