class Cms::SiteSetting < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Auth::Manager
  include Cms::Model::Rel::Site

  validates :site_id, :name, presence: true

  SSL_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  LINK_CHECK_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]

  SITE_CONFIGS = [
    { id: "common_ssl", name: "共有SSL",
      setting_name: :setting_site_common_ssl_label },
    { id: "admin_mail_sender", name: "管理者メール送信元アドレス",
      setting_name: :in_setting_site_admin_mail_sender },
    { id: "allowed_attachment_type", name: "添付ファイル/許可する種類",
      setting_name: :in_setting_site_allowed_attachment_type },
    { id: "file_upload_max_size", name: "添付ファイル最大サイズ",
      setting_name: :in_setting_site_file_upload_max_size },
    { id: "link_check", name: "リンクチェック機能",
      setting_name: :setting_site_link_check_label },
  ]

end
