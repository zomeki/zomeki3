class Cms::Admin::Data::FileNodesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:creator)
  end

  def pre_dispatch
    @parent = params[:parent] || '0'
  end

  def index
    @items = Cms::DataFileNode.readable.order(:name, :id)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Cms::DataFileNode.readable.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::DataFileNode.new(
      :concept_id => Core.concept(:id)
    )
  end

  def create
    @item = Cms::DataFileNode.new(file_node_params)
    @item.site_id = Core.site.id
    _create @item
  end

  def update
    @item = Cms::DataFileNode.find(params[:id])
    @item.attributes = file_node_params
    @old_concept_id  = @item.concept_id_was

    _update(@item) do
      if @old_concept_id != @item.concept_id
        Cms::DataFile.where(concept_id: @old_concept_id, node_id: @item.id).update_all(concept_id: @item.concept_id)
      end
    end
  end

  def destroy
    @item = Cms::DataFileNode.find(params[:id])
    _destroy @item
  end

  private

  def file_node_params
    params.require(:item).permit(:concept_id, :name, :title)
  end
end
