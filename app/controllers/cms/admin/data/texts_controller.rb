class Cms::Admin::Data::TextsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:creator)
  end

  def index
    @items = Cms::DataText.readable.order(:name, :id)
                          .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = Cms::DataText.readable.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Cms::DataText.new(
      :concept_id => Core.concept(:id),
      :state      => 'public',
    )
  end

  def create
    @item = Cms::DataText.new(text_params)
    @item.site_id = Core.site.id
    _create @item
  end

  def update
    @item = Cms::DataText.find(params[:id])
    @item.attributes = text_params
    _update @item
  end

  def destroy
    @item = Cms::DataText.find(params[:id])
    _destroy @item
  end

  private

  def text_params
    params.require(:item).permit(:body, :concept_id, :name, :state, :title, :in_creator => [:group_id, :user_id])
  end
end
