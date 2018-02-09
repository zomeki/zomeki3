class Approval::Admin::Mailer < ApplicationMailer
  def approval_request(options = {})
    @item = options[:item]
    @content = @item.content
    @approval_request = options[:approval_request]
    @approver = options[:approver]

    @preview_uri = preview_uri
    @approve_uri = approve_uri

    mail from: options[:from], to: options[:to], subject: "#{subject_prefix}：承認依頼メール"
  end

  def approved_notification(options = {})
    @item = options[:item]
    @content = @item.content
    @approval_request = options[:approval_request]
    @approver = options[:approver]

    @detail_uri = detail_uri

    mail from: options[:from], to: options[:to], subject: "#{subject_prefix}：承認完了メール"
  end

  def passbacked_notification(options = {})
    @item = options[:item]
    @content = @item.content
    @approval_request = options[:approval_request]
    @approver = options[:approver]
    @comment = options[:comment]

    @detail_uri = detail_uri

    mail from: options[:from], to: options[:to], subject: "#{subject_prefix}：差し戻しメール"
  end

  def pullbacked_notification(options = {})
    @item = options[:item]
    @content = @item.content
    @approval_request = options[:approval_request]
    @approver = options[:approver]
    @comment = options[:comment]

    @detail_uri = detail_uri

    mail from: options[:from], to: options[:to], subject: "#{subject_prefix}：引き戻しメール"
  end

  private

  def subject_prefix
    "#{@content.name}（#{@content.site.name}）"
  end

  def preview_uri
    @item.preview_uri
  end

  def detail_uri
    Addressable::URI.join(@item.content.site.main_admin_uri, @item.admin_uri).to_s
  end

  def approve_uri
    Addressable::URI.join(@item.content.site.main_admin_uri, @item.admin_uri(active_tab: 'approval')).to_s
  end
end
