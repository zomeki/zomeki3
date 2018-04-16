require 'csv'
class Survey::Admin::FormsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Approval::Controller::Admin::Approval

  keep_params :target, :target_state, :target_public

  def pre_dispatch
    @content = Survey::Content::Form.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @item = @content.forms.find(params[:id]) if params[:id].present?
  end

  def index
    criteria = form_criteria
    @items = Survey::FormsFinder.new(@content.forms, Core.user)
                                .search(criteria)
                                .distinct
                                .reorder(:sort_no)
                                .paginate(page: params[:page], per_page: params[:limit])
                                .preload(content: { public_node: :site })

    _index @items
  end

  def show
    _show @item
  end

  def new
    @item = @content.forms.build
  end

  def create
    @item = @content.forms.build(form_params)
    @item.state = new_state_from_params

    _create(@item, location: location_after_save) do
      send_approval_request_mail(@item) if @item.state_approvable?
    end
  end

  def update
    @item.attributes = form_params
    @item.state = new_state_from_params

    _update(@item, location: location_after_save) do
      send_approval_request_mail(@item) if @item.state_approvable?
    end
  end

  def destroy
    _destroy @item
  end

  def approve
    _approve @item do
      if @item.state_approved? && @content.publish_after_approved?
        @item.publish
        Sys::OperationLog.log(request, item: @item, do: 'publish')
      end
    end
  end

  def publish
    @item.publish if @item.publishable?
    redirect_to url_for(action: :show), notice: '公開処理が完了しました。'
  end

  def close
    @item.close if @item.closable?
    redirect_to url_for(action: :show), notice: '公開終了処理が完了しました。'
  end

  def duplicate(item)
    if dupe_item = item.duplicate
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to url_for(action: :index) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "複製処理に失敗しました。"
      respond_to do |format|
        format.html { redirect_to url_for(action: :show) }
        format.xml  { render xml: item.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def new_state_from_params
    state = params.keys.detect { |k| k =~ /^commit_/ }.to_s.sub(/^commit_/, '')
    if @content.form_state_options(Core.user).map(&:last).include?(state)
      state
    else
      nil
    end
  end

  def location_after_save
    lambda { |form| url_for(action: :edit, id: form) } if @item.state_draft?
  end

  def form_criteria
    criteria = params[:criteria] ? params[:criteria].to_unsafe_h : {}

    if params[:target_public].blank?
      if Core.user.has_auth?(:manager)
        params[:target] = 'all' if params[:target].blank?
        params[:target_state] = 'processing' if params[:target_state].blank?
      else
        params[:target] = 'user' if params[:target].blank? || params[:target] == 'all'
        params[:target_state] = 'processing' if params[:target_state].blank?
      end
    end

    if params[:target] == '' && params[:target_state] == ''
      criteria[:target] = 'all'
      criteria[:target_state] = 'public'
    else
      criteria[:target] = params[:target]
      criteria[:target_state] = params[:target_state]
    end

    criteria
  end

  def form_params
    params.require(:item).permit(
      :confirmation, :description, :index_link, :name,
      :receipt, :sitemap_state, :sort_no, :summary, :title, :mail_to,
      :creator_attributes => [:id, :group_id, :user_id],
      :tasks_attributes => [:id, :name, :process_at],
      :in_approval_flow_ids => []
    ).tap do |permitted|
      [:in_approval_assignment_ids].each do |key|
        permitted[key] = params[:item][key].to_unsafe_h if params[:item][key]
      end
    end
  end
end
