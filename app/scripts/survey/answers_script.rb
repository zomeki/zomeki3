class Survey::AnswersScript < Cms::Script::Base
  def pull
    ApplicationRecordSlave.each_slaves do
      form_answers = Survey::Slave::FormAnswer.where('created_at < ?', (Time.now - 5).strftime('%Y-%m-%d %H:%M:%S'))
      if ::Script.site
        form_ids = Survey::Form.where(
          content_id: Survey::Content::Form.select(:id).where(site_id: ::Script.site.id)
        ).pluck(:id)
        form_answers = form_answers.where(form_id: form_ids)
      end

      ::Script.total form_answers.size

      form_answers.each do |form_answer|
        ::Script.progress(form_answer) do
          pull_answers(form_answer)
          form_answer.destroy
        end
      end
    end
  end

  protected

  def pull_answers(s_form_answer)
    form_answer = Survey::FormAnswer.create(s_form_answer.attributes.except('id'))

    s_form_answer.answers.each do |s_answer|
      form_answer.answers.create(s_answer.attributes.except('id'))
    end

    #begin
    #  send_answer_mail(form_answer)
    #rescue => e
    #  error_log("メール送信失敗 #{e}")
    #end
  end

  def send_answer_mail(form_answer)
    content = form_answer.content
    Survey::Public::Mailer.survey_receipt(form_answer: form_answer, from: content.mail_from, to: content.mail_to)
                .deliver_now if content.mail_from.present? && content.mail_to.present?
  end
end
