class Cms::SiteSetting < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Setting
  include Cms::Model::Rel::Site
  include Cms::Model::Auth::Site

  set_config :basic_auth_state,
             name: 'ベーシック認証',
             default_value: 'disabled'
  set_config :common_ssl,
             name: '共有SSL',
             default_value: 'disabled',
             options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
             index: true
  set_config :admin_mail_sender,
             name: '管理者メール送信元アドレス',
             default_value: 'noreply',
             index: true
  set_config :allowed_attachment_type,
             name: '添付ファイル/許可する種類',
             default_value: '',
             index: true
  set_config :file_upload_max_size,
             name:  '添付ファイル最大サイズ',
             default_value: 5,
             index: true
  set_config :extension_upload_max_size,
             name: '拡張子別アップロードサイズ',
             default_value: ''
  set_config :link_check,
             name:  'リンクチェック機能',
             default_value: 'enabled',
             options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
             index: true
  set_config :link_check_hour,
             name: 'リンクチェック開始時刻',
             default_value: nil
  set_config :link_check_exclusion,
             name: 'リンクチェック対象外URL',
             default_value: ''
  set_config :accessibility_check,
             name: 'アクセシビリティチェック機能',
             default_value: 'enabled',
             options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
             index: true
  set_config :adobe_reader_link,
             name: 'Adobe Reader リンク',
             default_value: 'enabled',
             options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
             index: true
  set_config :kana_talk,
             name: 'ふりがな・音声',
             default_value: 'enabled',
             options: [['ふりがなと音声を書き出し', 'enabled'], ['ふりがなのみ書き出し', 'kana_only'], ['書き出さない', 'disabled']],
             index: true
  set_config :map_coordinate,
             name: '地図/デフォルト座標',
             default_value: nil,
             index: true

  validates :site_id, :name, presence: true
end
