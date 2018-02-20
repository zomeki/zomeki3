class Survey::AnswersScript < ParametersScript
  def pull
    ApplicationRecordSlave.each_slaves do
      s_form_answers = Survey::Slave::FormAnswer.date_before(:created_at, 5.minutes.ago)
      if ::Script.site
        form_ids = Survey::Form.in_site(::Script.site).pluck(:id)
        s_form_answers.where!(form_id: form_ids)
      end

      ::Script.total s_form_answers.size

      s_form_answers.each do |s_form_answer|
        ::Script.progress(s_form_answer) do
          pull_answers(s_form_answer)
          s_form_answer.destroy
        end
      end
    end
  end

  protected

  def pull_answers(s_form_answer)
    form_answer = Survey::FormAnswer.new(s_form_answer.attributes.except('id'))

    s_form_answer.answers.each do |s_answer|
      answer = form_answer.answers.build(s_answer.attributes.except('id'))
      if s_attachment = s_answer.attachment
        at = answer.build_attachment(s_attachment.attributes.except('id'))
        at.skip_upload
      end
    end

    form_answer.save(validate: false)
  end

  def send_answer_mail(form_answer)
    content = form_answer.content
    Survey::Public::Mailer.survey_receipt(form_answer: form_answer, from: content.mail_from, to: content.mail_to)
                .deliver_now if content.mail_from.present? && content.mail_to.present?
  end
end
