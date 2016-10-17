class Survey::Script::AnswersController < ApplicationController

  def pull
    ApplicationRecordSlave.each_slaves do
      s_form_answers = Survey::Slave::FormAnswer.where('created_at < ?', (Time.now - 5).strftime('%Y-%m-%d %H:%M:%S'))

      Script.total s_form_answers.size

      s_form_answers.each do |s_form_answer|
        Script.current
        pull_answers(s_form_answer)
        Script.success
      end

      s_form_answers.each(&:destroy)
    end

    render plain: 'OK'
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
