class Tag::Content::Setting < Cms::ContentSetting
  set_config :date_style,
    name: "#{GpArticle::Doc.model_name.human}日付形式",
    comment: I18n.t('comments.date_style'),
    default_value: '%Y年%m月%d日 %H時%M分'
  set_config :list_style,
    name: "#{GpArticle::Doc.model_name.human}表示形式",
    comment: I18n.t('comments.list_style'),
    default_value: '@title_link@(@publish_date@ @group@)'
end
