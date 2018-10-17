Cms::Lib::Modules::ModuleSet.draw :gp_calendar, 'カレンダー', 60 do |mod|
  ## contents
  mod.content :events, 'カレンダー', publishable: true

  ## directories
  mod.directory :events, 'イベント一覧'
  mod.directory :todays_events, '今日のイベント'
  mod.directory :calendar_styled_events, 'イベントカレンダー'
  mod.directory :search_events, 'イベント検索', dynamic: true

  ## pieces
  mod.piece :monthly_links, '月別リンク'
  mod.piece :daily_links, '日別リンク', publishable: true
  mod.piece :category_types, 'カテゴリ一覧'
  mod.piece :near_future_events, '本日と明日のイベント'
  mod.piece :events, 'イベント一覧'
  mod.piece :category_daily_links, '日別リンク（イベント検索）', publishable: true

  ## public models
  mod.public_model :events
  mod.public_model :holidays
end
