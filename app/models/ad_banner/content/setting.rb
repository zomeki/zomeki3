class AdBanner::Content::Setting < Cms::ContentSetting
  set_config :click_count_setting,
    name: 'クリック数カウント',
    form_type: :radio_buttons,
    options: [['有効', 'enabled'], ['無効', 'disabled']],
    default_value: 'enabled'
  set_config :image_display,
    name: 'バナー画像表示形式',
    form_type: :radio_buttons,
    options: [['画像をリンクにする', 'link'], ['画像をHTMLに埋め込む', 'embed']],
    default_value: 'link'

  belongs_to :content, foreign_key: :content_id, class_name: 'AdBanner::Content::Banner'
end
