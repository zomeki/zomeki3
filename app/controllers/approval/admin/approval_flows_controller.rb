class Approval::Admin::ApprovalFlowsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Approval::Content::ApprovalFlow.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    return user_options if params[:user_options]

    @items = @content.approval_flows.paginate(page: params[:page], per_page: 30).order(:sort_no)
    _index @items
  end

  def show
    @item = @content.approval_flows.find(params[:id])
    _show @item
  end

  def new
    @item = @content.approval_flows.build
  end

  def create
    @item = @content.approval_flows.build(approval_params)
    _create(@item) do
      set_approvals
    end
  end

  def update
    @item = @content.approval_flows.find(params[:id])
    @item.attributes = approval_params
    _update(@item) do
      set_approvals
    end
  end

  def destroy
    @item = @content.approval_flows.find(params[:id])
    _destroy @item
  end

  private

  def user_options
    group = Sys::Group.find(params[:group_id])
    options = [["*自所属ユーザー", "gu0"],["*#{group.name}所属ユーザー", "gu#{group.id}"]] + group.users.map { |u| [u.name, u.id] }
    render plain: view_context.options_for_select(options), layout: false
  end

  def set_approvals
    return unless params[:approvals]

    indexes = params[:approvals].keys
    @item.approvals.each { |a| a.destroy unless indexes.include?(a.index.to_s) }

    params[:approvals].each do |key, value|
      next unless value.is_a?(Array)

      approval = @item.approvals.where(index: key).first_or_initialize
      approval.approval_type = params[:approval_types][key]
      approval.save! if approval.changed?
      approval.assignments.destroy_all

      value.each_with_index do |ids, ogid|
        ids.split(",").each do |id|
          if match = id.match(/^gu(\d+)/)
            approval.assignments.create(group_id: match[1], or_group_id: ogid, assign_type: 'group_users')
          else
            approval.assignments.create(user_id: id, or_group_id: ogid, assign_type: 'user')
          end
        end
      end
    end
  end

  def approval_params
    params.require(:item).permit(:title, :group_id, :sort_no, :approval_types, :approvals)
  end
end
