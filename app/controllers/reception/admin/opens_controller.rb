class Reception::Admin::OpensController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return redirect_to(action: :index) if params[:reset_criteria]
    @content = Reception::Content::Course.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @course = @content.courses.find(params[:course_id])

    @item = @course.opens.find(params[:id]) if params[:id].present?
  end

  def index
    @items = @course.opens.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    _show @item
  end

  def new
    @item = @course.opens.build
  end

  def create
    @item = @course.opens.build(open_params)
    @item.state = params[:commit_public].present? ? 'public' : 'draft'
    _create @item
  end

  def update
    @item.attributes = open_params
    @item.state = params[:commit_public].present? ? 'public' : 'draft'
    _update @item
  end

  def destroy
    _destroy @item
  end

  def publish(item)
    item.state = 'public'
    _update item
  end

  def close(item)
    item.state = 'closed'
    _update item
  end

  private

  def open_params
    params.require(:item).permit(
      :title, :open_on, :start_at, :end_at, :place, :lecturer, :expired_at,
      :creator_attributes => [:id, :group_id, :user_id]
    )
  end
end
