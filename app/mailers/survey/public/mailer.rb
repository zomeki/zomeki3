class Survey::Public::Mailer < ApplicationMailer
  def survey_receipt(form_answer:, from:, to:)
    raise ArgumentError.new("emails required. (from: #{from}, to: #{to})") if from.to_s.blank? || to.to_s.blank?

    content = form_answer.form.content
    @form_answer = form_answer

    mail from: from, to: to, subject: "#{@form_answer.form.title}（#{content.site.name}）：回答メール"
  end

  def survey_auto_reply(form_answer:, from:, to:)
    raise ArgumentError.new("emails required. (from: #{from}, to: #{to})") if from.to_s.blank? || to.to_s.blank?

    @content = form_answer.form.content
    @form_answer = form_answer

    mail from: from, to: to, subject: "#{@form_answer.form.title}（#{@content.site.name}）：受信確認自動返信メール"
  end
end
