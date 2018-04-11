class Sys::Admin::AccountMailer < ApplicationMailer
  def password_reminder(site, user:)
    @site = site
    @user = user

    mail from: @site.admin_mail_sender, to: user.email, subject: "【#{@site.name}】パスワード再設定"
  end
end
