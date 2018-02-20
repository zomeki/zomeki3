class Survey::Admin::FormAnswersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Survey::Content::Form.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to url_for(action: :index) if params[:reset_criteria]
    @form = @content.forms.find(params[:form_id])
    @item = @form.form_answers.find(params[:id]) if params[:id].present?
  end

  def index
    @items = Survey::FormAnswersFinder.new(@form.form_answers)
                                      .search(params[:criteria])

    if params[:csv]
      csv = generate_csv(@items)
      return send_data platform_encode(csv), type: 'text/csv', filename: "answers_#{Time.now.to_i}.csv"
    end

    @items = @items.paginate(page: params[:page], per_page: 30)

    _index @items
  end

  def show
    _show @item
  end

  def destroy
    if @item.form.deletable? && @item.destroy
      redirect_to url_for(:action => :index), notice: "削除処理が完了しました。（#{I18n.l Time.now}）"
    else
      redirect_to url_for(:action => :show), alert: '削除処理に失敗しました。'
    end
  end

  private

  def generate_csv(items)
    CSV.generate do |csv|
      header = [Survey::FormAnswer.human_attribute_name(:id),
                Survey::FormAnswer.human_attribute_name(:created_at),
                "#{Survey::FormAnswer.human_attribute_name(:answered_url)}URL",
                "#{Survey::FormAnswer.human_attribute_name(:answered_url)}タイトル",
                Survey::FormAnswer.human_attribute_name(:remote_addr),
                Survey::FormAnswer.human_attribute_name(:user_agent)]

      @form.questions.each { |q| header << q.title }

      csv << header

      items.each do |item|
        line = [item.id,
                I18n.l(item.created_at),
                item.answered_full_uri,
                item.answered_url_title,
                item.remote_addr,
                item.user_agent]

        @form.questions.each { |q| line << item.answers.find_by(question_id: q.id).try(:content) }

        csv << line
      end
    end
  end
end
