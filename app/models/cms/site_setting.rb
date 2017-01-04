class Cms::SiteSetting < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Auth::Manager
  include Cms::Model::Rel::Site

  validates :site_id, :name, presence: true

  SITE_CONFIGS = [
    {id: "common_ssl", name: "共有SSL", setting_name: :setting_site_common_ssl_label, default: 'disabled',
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']], form_type: :radio_buttons},
    {id: "admin_mail_sender", name: "管理者メール送信元アドレス",
      setting_name: :in_setting_site_admin_mail_sender, default: 'noreply'},
    {id: "allowed_attachment_type", name: "添付ファイル/許可する種類",
      setting_name: :in_setting_site_allowed_attachment_type, default: 'gif,jpg,png,pdf,doc,docx,xls,xlsx,ppt,pptx,odt,ods,odp'},
    {id: "file_upload_max_size", name: "添付ファイル最大サイズ",
      setting_name: :in_setting_site_file_upload_max_size, comment: 'MB', default: '50'}
  ]

  SSL_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]

end
