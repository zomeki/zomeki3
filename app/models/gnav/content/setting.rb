class Gnav::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id,
    name: 'カテゴリ種別',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map { |ct| [ct.name, ct.id] } }

  belongs_to :content, foreign_key: :content_id, class_name: 'Gnav::Content::MenuItem'
end
