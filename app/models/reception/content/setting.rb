class Reception::Content::Setting < Cms::ContentSetting
  include GpCategory::Model::Rel::Content::Setting::CategoryTypeId

  set_config :gp_category_content_category_type_id,
    name: 'カテゴリ',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map { |ct| [ct.name, ct.id] } }
  set_config :mail_from,
    name: '差出人メールアドレス'
  set_config :mail_to,
    name: '通知先メールアドレス'
  set_config :auto_reply,
    name: "自動返信メール",
    options: [['返信する','send'],['返信しない','none']],
    default_value: 'send'
  set_config :doc_list_style,
    name: "講座一覧表示形式",
    options: [['全講座一覧','all_courses'],['カテゴリ一覧','all_categories']],
    default_value: 'all_courses'
  set_config :list_style,
    name: "講座タイトル表示形式",
    form_type: :text_area,
    default_value: '@title',
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>'

  belongs_to :content, foreign_key: :content_id, class_name: 'Reception::Content::Course'

  validate :validate_value

  private

  def validate_value
    case name
    when 'mail_from', 'mail_to'
      errors.add :value, :blank if value.blank?
    end
  end
end
