class CommonMailer < ApplicationMailer
  def plain(options)
    @body_text = options[:body]
    mail from: options[:from],
         to: options[:to],
         subject: options[:subject]
  end

  def survey_receipt(form_answer: nil, from: nil, to: nil)
    raise ArgumentError.new('form_answer required.') unless form_answer.kind_of?(Survey::FormAnswer)
    raise ArgumentError.new("emails required. (from: #{from}, to: #{to})") if from.to_s.blank? || to.to_s.blank?

    content = form_answer.form.content
    @form_answer = form_answer

    mail from: from,
         to: to,
         subject: "#{@form_answer.form.title}（#{content.site.name}）：回答メール"
  end

  def survey_auto_reply(form_answer: nil, from: nil, to: nil)
    raise ArgumentError.new('form_answer required.') unless form_answer.kind_of?(Survey::FormAnswer)
    raise ArgumentError.new("emails required. (from: #{from}, to: #{to})") if from.to_s.blank? || to.to_s.blank?

    @content = form_answer.form.content
    @form_answer = form_answer

    mail from: from,
         to: to,
         subject: "#{@form_answer.form.title}（#{@content.site.name}）：受信確認自動返信メール"
  end

  def commented_notification(comment)
    @doc = comment.doc
    @core_uri = Cms::SiteSetting::AdminProtocol.core_domain @doc.content.site, @doc.content.site.full_uri

    from = comment.author_name
    from << " <#{comment.author_email}>" if comment.author_email.present?

    return if from.blank? || @doc.creator.user.email.blank?

    mail from: from,
         to: @doc.creator.user.email,
         subject: "#{@doc.content.name}（#{@doc.content.site.name}）：コメント通知メール"
  end
end
