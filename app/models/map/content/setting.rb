class Map::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id,
    name: 'カテゴリ種別',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map { |ct| [ct.name, ct.id] } }
  set_config :lat_lng,
    name: '地図/デフォルト座標',
    comment: '（緯度,経度）'
  set_config :show_images,
    name: '画像表示',
    form_type: :radio_buttons,
    options: [['表示', 'visible'], ['非表示', 'hidden']]
  set_config :default_image,
    name: '初期画像',
    comment: '（例 /images/sample.jpg ）'
  set_config :marker_order,
    name: '並び順',
    options: [['投稿日（昇順）', 'time_asc'], ['投稿日（降順）', 'time_desc'], ['カテゴリ順', 'category']]
  set_config :title_style,
    name: "タイトル表示形式",
    form_type: :text,
    upper_text: "<p><strong>タイトル（リンクなし）：</strong>@title@ <strong>タイトル（リンクあり）：</strong>@title_link@ <strong>サブタイトル：</strong>@subtitle@ <strong>概要：</strong>@summary@",
    default_value: '@title_link@'

  belongs_to :content, foreign_key: :content_id, class_name: 'Map::Content::Marker'

  def extra_values=(params)
    ex = extra_values
    case name
    when 'gp_category_content_category_type_id'
      category_ids = (params[:categories] || {}).values.map(&:last)
      ex[:category_ids] = category_ids.map{|id| id.to_i if id.present? }.compact.uniq
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
