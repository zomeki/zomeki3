class Gnav::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id,
    name: 'カテゴリ種別',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map { |ct| [ct.name, ct.id] } }
  set_config :date_style,
    name: "#{GpArticle::Doc.model_name.human}日付形式",
    comment: I18n.t('comments.date_style'),
    default_value: '%Y年%m月%d日 %H時%M分'
  set_config :list_style,
    name: "#{GpArticle::Doc.model_name.human}表示形式",
    comment: I18n.t('comments.list_style'),
    default_value: '@title_link@(@publish_date@ @group@)'

  belongs_to :content, foreign_key: :content_id, class_name: 'Gnav::Content::MenuItem'
end
