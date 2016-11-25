class GpCalendar::Content::Setting < Cms::ContentSetting
  set_config :gp_category_content_category_type_id,
    name: 'カテゴリ種別',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map { |ct| [ct.name, ct.id] } }
  set_config :date_style,
    name: '日付形式',
    comment: '<strong>年：</strong>%Y <strong>月：</strong>%m <strong>日：</strong>%d <strong>曜日：</strong>%A <strong>曜日（省略）：</strong>%a',
    default_value: '%Y年%m月%d日（%a）'
  set_config :list_style,
    name: '表示形式/イベント一覧',
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>',
    form_type: :table_field,
    default_value: [{header: 'タイトル', data: '@title_link@'}]
  set_config :today_list_style,
    name: '表示形式/今日のイベント',
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>',
    form_type: :table_field,
    default_value: [{header: 'タイトル', data: '@title_link@'}]
  set_config :calendar_list_style,
    name: '表示形式/イベントカレンダー',
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>',
    default_value: '@title_link@'
  set_config :search_list_style,
    name: '表示形式/イベント検索',
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>',
    form_type: :table_field,
    default_value: [{header: 'タイトル', data: '@title_link@'}]
  set_config :default_image,
    name: '初期画像',
    comment: '（例 /images/sample.jpg ）'
  set_config :show_qreki,
    name: '旧暦表示',
    options: [["表示する", 1], ["表示しない", 0]]
  set_config :event_sync_import,
    name: 'イベント同期（インポート）',
    options: [['有効', 'enabled'], ['無効', 'disabled']],
    default_value: 'disabled'
  set_config :event_sync_export,
    name: 'イベント同期（エクスポート）',
    options: [['有効', 'enabled'], ['無効', 'disabled']],
    default_value: 'disabled'

  belongs_to :content, foreign_key: :content_id, class_name: 'GpCalendar::Content::Event'

  def extra_values=(params)
    ex = extra_values
    case name
    when 'gp_category_content_category_type_id'
      ex[:category_type_ids] = params[:category_types].map(&:to_i).uniq
    when 'event_sync_import'
      ex[:source_hosts] = params[:source_hosts].to_s
    when 'event_sync_export'
      ex[:destination_hosts] = params[:destination_hosts].to_s
      ex[:default_will_sync] = params[:default_will_sync].to_s
    when 'list_style', 'today_list_style', 'search_list_style'
      ex[:headers] = params[:headers]
      ex[:values]  = params[:values]
    end
    super(ex)
  end


  def category_ids
    extra_values[:category_ids] || []
  end

  def category_type_ids
    extra_values[:category_type_ids] || []
  end

  def categories
    GpCategory::Category.where(id: category_ids)
  end

  def category_types
    GpCategory::CategoryType.where(id: category_type_ids)
  end

end
