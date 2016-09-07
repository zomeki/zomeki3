class Cms::SiteSetting < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Auth::Manager
  include Cms::Model::Rel::Site

  validates :site_id, :name, presence: true

  SITE_CONFIGS = [
    {id: "common_ssl", name: "共有SSL", setting_name: :in_setting_site_common_ssl ,default: 'disabled',
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']], form_type: :radio_buttons},
    {id: "pass_reminder_mail_sender", name: "パスワード変更メール送信元アドレス",
      setting_name: :in_setting_site_pass_reminder_mail_sender , default: 'noreply'},
    {id: "file_upload_max_size", name: "添付ファイル最大サイズ",
      setting_name: :in_setting_site_file_upload_max_size , comment: 'MB', default: '50'}
  ]

  SSL_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]


  def self.site_configs
    SITE_CONFIGS
  end
end
