class Organization::Content::Setting < Cms::ContentSetting
  set_config :article_relation,
    name: '記事URL保持許可',
    form_type: :radio_buttons,
    options: Organization::Content::Group::ARTICLE_RELATION_OPTIONS,
    default_value: 'disabled'
  set_config :doc_style,
    name: "#{GpArticle::Doc.model_name.human}表示形式",
    form_type: :text_area,
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>',
    default_value: '@title_link@(@publish_date@ @group@)'
  set_config :date_style,
    name: "#{GpArticle::Doc.model_name.human}日付形式",
    comment: I18n.t('comments.date_style'),
    default_value: '%Y年%m月%d日'
  set_config :time_style,
    name: "#{GpArticle::Doc.model_name.human}時間形式",
    comment: I18n.t('comments.time_style'),
    default_value: '%H時%M分'
  set_config :num_docs,
    name: "#{GpArticle::Doc.model_name.human}表示件数",
    default_value: '10'
  set_config :gp_category_content_category_type_id,
    name: 'カテゴリ種別',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map { |ct| [ct.name, ct.id] } }

  validate :validate_value

  private

  def validate_value
    case name
    when 'num_docs'
      errors.add :value, :not_a_number unless value =~ /^\d+$/
    end
  end
end
