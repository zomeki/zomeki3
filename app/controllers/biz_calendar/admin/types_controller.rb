class BizCalendar::Admin::TypesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = BizCalendar::Content::Place.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to action: :index if params[:reset]
  end

  def index
    @items = BizCalendar::HolidayType.where(content_id: @content.id).order(updated_at: :desc, id: :desc)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = BizCalendar::HolidayType.find(params[:id])
    #return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = @content.types.build
  end

  def create
    @item = @content.types.build(holiday_type_params)
    _create(@item)
  end

  def update
    @item = @content.types.find(params[:id])
    @item.attributes = holiday_type_params
    _update(@item)
  end

  def destroy
    @item = @content.types.find(params[:id])
    _destroy @item
  end

  private

  def holiday_type_params
    params.require(:item).permit(:state, :title, :name, :creator_attributes => [:id, :group_id, :user_id])
  end
end
