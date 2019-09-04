class Survey::Content::Setting < Cms::ContentSetting
  set_config :mail_from,
    name: '差出人メールアドレス'
  set_config :mail_to,
    name: '通知先メールアドレス'
  set_config :approval_relation,
    name: '承認フロー',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    extra_options: {
      publish_after_approved_options: [['使用する', 'enabled'], ['使用しない', 'disabled']]
    },
    default_value: 'disabled',
    default_extra_values: {
      approval_content_id: nil,
      publish_after_approved: 'disabled'
    }
  set_config :captcha,
    name: '画像認証',
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    default_value: 'disabled'
  set_config :common_ssl,
    name: '共有SSL',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    default_value: 'disabled'
  set_config :auto_reply,
    name: "自動返信メール",
    options: [['返信する','send'],['返信しない','none']],
    default_value: 'none',
    default_extra_values: {
      upper_reply_text: nil,
      lower_reply_text: nil,
    }
  set_config :block_word,
    name: '禁止語句',
    form_type: :text,
    lower_text: 'スペースまたは改行で複数指定できます。'

  belongs_to :content, foreign_key: :content_id, class_name: 'Survey::Content::Form'

  validate :validate_value

  def extra_values=(params)
    ex = extra_values
    case name
    when 'approval_relation'
      ex[:approval_content_id] = params[:approval_content_id].to_i
      ex[:publish_after_approved] = params[:publish_after_approved]
    when 'auto_reply'
      ex[:upper_reply_text] = params[:upper_reply_text]
      ex[:lower_reply_text] = params[:lower_reply_text]
    end
    super(ex)
  end

  private

  def validate_value
    case name
    when 'mail_from', 'mail_to'
      if value.present? && value !~ /\A.+@.+\z/
        errors.add :value, :email
      end
    end
  end
end
