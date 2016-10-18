class Survey::Content::Setting < Cms::ContentSetting
  set_config :mail_from,
    name: '差出人メールアドレス'
  set_config :mail_to,
    name: '通知先メールアドレス'
  set_config :approval_relation,
    name: '承認フロー',
    form_type: :radio_buttons,
    options: Survey::Content::Form::APPROVAL_RELATION_OPTIONS,
    default_value: 'disabled'
  set_config :captcha,
    name: '画像認証',
    options: Survey::Content::Form::CAPTCHA_OPTIONS
  set_config :common_ssl,
    name: '共有SSL',
    form_type: :radio_buttons,
    options: Survey::Content::Form::SSL_OPTIONS
  set_config :auto_reply,
    name: "自動返信メール",
    options: [['返信する','send'],['返信しない','none']]

  validate :validate_value

  private

  def validate_value
    case name
    when 'mail_from', 'mail_to'
      errors.add :value, :blank if value.blank?
    end
  end
end
