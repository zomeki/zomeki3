class GpCategory::Content::Setting < Cms::ContentSetting
  set_config :group_category_type_name,
    name: "組織用#{GpCategory::CategoryType.human_attribute_name :name}",
    comment: '初期値 ： groups',
    default_value: 'groups'
  set_config :list_style,
    name: "#{GpArticle::Doc.model_name.human}表示形式",
    form_type: :text_area,
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>',
    default_value: '@title_link@(@publish_date@ @group@)'
  set_config :date_style,
    name: "#{GpArticle::Doc.model_name.human}日付形式",
    comment: I18n.t('comments.date_style'),
    default_value: '%Y年%m月%d日 %H時%M分'
  set_config :time_style,
    name: "#{GpArticle::Doc.model_name.human}時間形式",
    comment: I18n.t('comments.time_style'),
    default_value: '%H時%M分'
  set_config :category_type_style,
    name: "#{GpCategory::CategoryType.model_name.human}表示形式",
    options: GpCategory::Content::CategoryType::CATEGORY_TYPE_STYLE_OPTIONS
  set_config :category_style,
    name: "#{GpCategory::Category.model_name.human}表示形式",
    options: GpCategory::Content::CategoryType::CATEGORY_STYLE_OPTIONS
  set_config :doc_style,
    name: '新着記事一覧表示形式',
    options: GpCategory::Content::CategoryType::DOC_STYLE_OPTIONS
  set_config :docs_order,
    name: '記事一覧表示順',
    options: GpCategory::Content::CategoryType::DOCS_ORDER_OPTIONS,
    default_value: 'published_at_desc'
  set_config :index_template_id,
    name: 'index設定',
    options: lambda {->(content=nil) do
        if content
          GpCategory::Content::CategoryType.find_by(id: content.id).templates.map{|t| [t.title, t.id] }
        else
          []
        end
      end}
  set_config :feed,
    name: "フィード",
    form_type: :radio_buttons,
    options: GpCategory::Content::CategoryType::FEED_DISPLAY_OPTIONS,
    default_value: 'enabled',
    default_extra_values: { feed_docs_number: 10 }
end
