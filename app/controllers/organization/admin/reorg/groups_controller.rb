class Organization::Admin::Reorg::GroupsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Organization::Content::Group.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)

    @parent = Organization::Reorg::Group.find_by(content: @content, sys_group_code: params[:parent]) if params[:parent]
    @item = Organization::Reorg::Group.find_by(content: @content, id: params[:id]) if params[:id]
  end

  def index
    @items = if @parent
               @parent.children
             else
               codes = Sys::Reorg::Group.in_site(@content.site).where(level_no: 2).pluck(:code)
               Organization::Reorg::Group.where(content: @content, sys_group_code: codes)
             end

    @items = @items.paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
  end

  def edit
  end

  def update
    @item.attributes = group_params
    _update @item do
      @item.change_state = @item.detect_change_state
      @item.save
    end
  end

  private

  def group_params
    params.require(:item).permit(
      :outline, :business_outline, :concept_id, :contact_information,
      :docs_order, :layout_id, :more_layout_id, :sitemap_state, :sort_no, :state,
      :creator_attributes => [:id, :group_id, :user_id]
    )
  end
end
