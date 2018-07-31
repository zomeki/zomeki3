class Sys::Admin::RecognitionMailer < ApplicationMailer
  def recognition_request(item, from:, to:)
    @item = item
    @site = item.site
    @from = from
    @to = to

    mail from: from_address, to: @to.email, subject: "ページ（#{@site.name}）：承認依頼メール"
  end

  def recognition_success(item, from:, to:)
    @item = item
    @site = item.site
    @from = from
    @to = to

    mail from: from_address, to: @to.email, subject: "ページ（#{@site.name}）：最終承認完了メール"
  end

  private

  def from_address
    if @site.admin_mail_sender_for_approval?
      @site.admin_mail_sender
    else
      @from.email
    end
  end
end
