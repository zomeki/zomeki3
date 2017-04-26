class Tag::Content::Setting < Cms::ContentSetting
  set_config :date_style,
    name: "#{GpArticle::Doc.model_name.human}日付形式",
    comment: I18n.t('comments.date_style'),
    default_value: '%Y年%m月%d日 %H時%M分'
  set_config :list_style,
    name: "#{GpArticle::Doc.model_name.human}表示形式",
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>',
    default_value: '@title_link@(@publish_date@ @group@)'

  belongs_to :content, foreign_key: :content_id, class_name: 'Tag::Content::Tag'
end
