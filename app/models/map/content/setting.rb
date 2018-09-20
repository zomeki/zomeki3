class Map::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id,
    name: 'カテゴリ種別',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map { |ct| [ct.name, ct.id] } },
    default_extra_values: {
      category_ids: []
    }
  set_config :lat_lng,
    name: '地図/デフォルト座標',
    comment: '（緯度,経度）'
  set_config :list_style,
    name: '一覧表示形式',
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>',
    form_type: :table_field,
    default_value: [{ header: 'カテゴリ', data: '@category@' },
                    { header: '画像', data: '@image@' },
                    { header: '名称', data: '@title_link@' },
                    { header: '地図', data: '@marker_link@' }]
  set_config :default_image,
    name: '初期画像',
    comment: '（例 /images/sample.jpg ）'
  set_config :marker_order,
    name: '並び順',
    options: [['投稿日（昇順）', 'time_asc'], ['投稿日（降順）', 'time_desc'], ['カテゴリ順', 'category'], ['並び順番号', 'sort_no']]

  belongs_to :content, foreign_key: :content_id, class_name: 'Map::Content::Marker'

  def extra_values=(params)
    ex = extra_values
    case name
    when 'gp_category_content_category_type_id'
      ex[:category_ids] = params[:category_ids].to_a.select(&:present?).map(&:to_i).uniq
    end
    super(ex)
  end

  def category_ids
    extra_values[:category_ids] || []
  end

  def categories
    GpCategory::Category.where(id: category_ids)
  end
end
