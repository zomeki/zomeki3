class Cms::SiteSetting < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Site
  include Cms::Model::Auth::Site

  validates :site_id, :name, presence: true

  SSL_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  LINK_CHECK_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  ACCESSIBILITY_CHECK_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]
  KANA_TALK_OPTIONS = [['ふりがなと音声を書き出し', 'enabled'], ['ふりがなのみ書き出し', 'kana_only'], ['書き出さない', 'disabled']]

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
    { id: "accessibility_check", name: "アクセシビリティチェック機能",
      setting_name: :setting_site_accessibility_check_label },
    { id: "kana_talk", name: "ふりがな・音声",
      setting_name: :setting_site_kana_talk_label },
  ]
end
