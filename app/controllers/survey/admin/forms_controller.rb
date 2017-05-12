require 'csv'
class Survey::Admin::FormsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Survey::Content::Form.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @item = @content.forms.find(params[:id]) if params[:id].present?
  end

  def index
    criteria = params[:criteria] || {}

    case params[:target]
    when 'all'
      # No criteria
    when 'draft'
      criteria[:state] = 'draft'
      criteria[:touched_user_id] = Core.user.id
    when 'public'
      criteria[:state] = 'public'
      criteria[:touched_user_id] = Core.user.id
    when 'closed'
      criteria[:state] = 'closed'
      criteria[:touched_user_id] = Core.user.id
    when 'approvable'
      criteria[:approvable] = true
      criteria[:state] = 'approvable'
    when 'approved'
      criteria[:approvable] = true
      criteria[:state] = 'approved'
    else
      criteria[:editable] = true
    end

    @items = Survey::Form.all_with_content_and_criteria(@content, criteria).reorder(:sort_no)
      .paginate(page: params[:page], per_page: 30)
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
    new_state = params.keys.detect{|k| k =~ /^commit_/ }.try(:sub, /^commit_/, '')

    @item = @content.forms.build(form_params)

    @item.state = new_state if new_state.present? && @item.class::STATE_OPTIONS.any?{|v| v.last == new_state }

    location = ->(f){ edit_survey_form_url(@content, f) } if @item.state_draft?
    _create(@item, location: location) do
      @item.send_approval_request_mail if @item.state_approvable?
    end
  end

  def update
    new_state = params.keys.detect{|k| k =~ /^commit_/ }.try(:sub, /^commit_/, '')

    @item.attributes = form_params

    @item.state = new_state if new_state.present? && @item.class::STATE_OPTIONS.any?{|v| v.last == new_state }

    location = url_for(action: 'edit') if @item.state_draft?
    _update(@item, location: location) do
      @item.send_approval_request_mail if @item.state_approvable?
    end
  end

  def destroy
    _destroy @item
  end

  def download_form_answers
    csv_string = CSV.generate do |csv|
      header = [Survey::FormAnswer.human_attribute_name(:created_at),
                "#{Survey::FormAnswer.human_attribute_name(:answered_url)}URL",
                "#{Survey::FormAnswer.human_attribute_name(:answered_url)}タイトル",
                Survey::FormAnswer.human_attribute_name(:remote_addr),
                Survey::FormAnswer.human_attribute_name(:user_agent)]

      @item.questions.each{|q| header << q.title }

      csv << header

      @item.form_answers.each do |form_answer|
        line = [I18n.l(form_answer.created_at),
                form_answer.answered_url,
                form_answer.answered_url_title,
                form_answer.remote_addr,
                form_answer.user_agent]

        @item.questions.each{|q| line << form_answer.answers.find_by(question_id: q.id).try(:content) }

        csv << line
      end
    end

    send_data csv_string.encode(Encoding::WINDOWS_31J, :invalid => :replace, :undef => :replace),
              type: Rack::Mime.mime_type('.csv'), filename: 'answers.csv'
  end

  def approve
    if @item.state_approvable? && @item.approvers.include?(Core.user)
      @item.approve(Core.user) do
        @item.update_column(:state, 'approved')
        @item.enqueue_tasks
        Sys::OperationLog.log(request, item: @item)
      end
    end
    redirect_to url_for(:action => :show), notice: '承認処理が完了しました。'
  end

  def publish
    @item.publish if @item.state_approved? && @item.approval_participators.include?(Core.user)
    redirect_to url_for(:action => :show), notice: '公開処理が完了しました。'
  end

  def close
    @item.close if @item.state_public? && @item.approval_participators.include?(Core.user)
    redirect_to url_for(:action => :show), notice: '非公開処理が完了しました。'
  end

  def duplicate(item)
    if dupe_item = item.duplicate
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to url_for(:action => :index) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "複製処理に失敗しました。"
      respond_to do |format|
        format.html { redirect_to url_for(:action => :show) }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def form_params
    params.require(:item).permit(
      :closed_at, :confirmation, :description, :index_link, :name, :opened_at,
      :receipt, :sitemap_state, :sort_no, :summary, :title,
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
