## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
calendar = create_cms_content c_content, 'GpCalendar::Event', 'イベント', 'event'

l_event     = create_cms_layout c_site, 'event-calendar', 'イベント'
create_cms_content_node calendar, l_event, 'GpCalendar::CalendarStyledEvent', 'calendar', 'イベントカレンダー'
create_cms_content_node calendar, l_event, 'GpCalendar::Event', 'event_list', 'イベント一覧'
create_cms_content_node calendar, l_event, 'GpCalendar::TodaysEvent', 'todays_event', '今日のイベント'

