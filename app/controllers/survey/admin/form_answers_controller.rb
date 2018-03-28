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
    elsif params[:attachments]
      answers = @form.answers.where(form_answer_id: @items.select(:id))
      total_size = Survey::Attachment.where(answer_id: answers.select(:id)).sum(:size)
      if total_size == 0
        return redirect_to url_for(action: :index), notice: '添付ファイルは見つかりませんでした。'
      elsif total_size > 100 * 1024**2
        return redirect_to url_for(action: :index), notice: 'ファイルサイズが100MBを超えています。ダウンロード対象を絞り込んでください。'
      else
        data = Survey::AttachmentCompressService.new(answers).compress
        return send_data data, type: 'application/zip', filename: "attachments_#{Time.now.to_i}.zip"
      end
    end

    @items = @items.paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    if params[:do] == 'download'
      answer = @item.answers.find_by(id: params[:answer_id])
      return http_error(404) if answer.nil? || (attachment = answer.attachment).nil?
      return send_data attachment.data, type: attachment.mime_type, filename: attachment.name, disposition: :attachment
    end

    _show @item
  end

  def destroy
    if @item.form.deletable? && @item.destroy
      redirect_to url_for(action: :index), notice: "削除処理が完了しました。（#{I18n.l Time.now}）"
    else
      redirect_to url_for(action: :show), alert: '削除処理に失敗しました。'
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
