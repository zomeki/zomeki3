class AdBanner::Content::Setting < Cms::ContentSetting
  set_config :click_count_setting,
    name: 'クリック数カウント',
    form_type: :radio_buttons,
    options: [['有効', 'enabled'], ['無効', 'disabled']],
    default_value: 'enabled'

  belongs_to :content, foreign_key: :content_id, class_name: 'AdBanner::Content::Banner'
end
