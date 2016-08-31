class CommonMailer < ApplicationMailer
  def plain(options)
    @body_text = options[:body]
    mail from: options[:from],
         to: options[:to],
         subject: options[:subject]
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
