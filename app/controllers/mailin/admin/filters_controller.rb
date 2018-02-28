class Mailin::Admin::FiltersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Mailin::Content::Filter.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)

    @item = @content.filters.find(params[:id]) if params[:id].present?
  end

  def index
    @items = @content.filters.order(:sort_no, :id)
                             .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    _show @item
  end

  def new
    @item = @content.filters.build(state: 'enabled')
  end

  def create
    @item = @content.filters.build(item_params)
    _create @item
  end

  def update
    @item.attributes = item_params
    _update @item
  end

  def destroy
    _destroy @item
  end

  private

  def item_params
    params.require(:item).permit(:state, :from, :to, :include_cc, :subject, :logic,
                                 :dest_content_id, :default_user_id, :sort_no)
  end
end
