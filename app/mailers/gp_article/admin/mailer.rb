class GpArticle::Admin::Mailer < ApplicationMailer
  def broken_link_notification(doc, src_doc)
    @doc = doc
    @src_doc = src_doc

    to = @src_doc.creator.try(:user).try(:email)
    return if to.blank?

    @detail_uri = gp_article_doc_url(host: host, content: @src_doc.content, concept: @src_doc.content.try(:concept_id), id: @src_doc.id)

    mail from: @doc.content.site.setting_site_admin_mail_sender,
         to: to,
         subject: "【#{@src_doc.content.site.name.presence || 'CMS'}】リンク切れ通知"
  end

  private

  def host
    @src_doc.content.site.main_admin_uri.sub(/\/+$/, '')
  end
end
