class RenamePassReminderMailSenderToMailSenderInCmsSiteSettings < ActiveRecord::Migration[5.0]
  def change
    execute "update cms_site_settings set name = 'admin_mail_sender' where name = 'pass_reminder_mail_sender'"
  end
end
