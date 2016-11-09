## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first
c_event = Cms::Concept.where(name: 'イベント').first

## ---------------------------------------------------------
## cms/contents
calendar = create_cms_content c_content, 'GpCalendar::Event', 'イベント', 'event'

category   = GpCategory::Content::CategoryType.first
event_type = GpCategory::CategoryType.where(name: 'event').first
categories = {}
GpCategory::Category.where(category_type_id: event_type.id).each_with_index{|c, i| categories[i.to_s] = c.id}

setting = GpCalendar::Content::Setting.config(calendar, 'gp_category_content_category_type_id')
setting.value = category.id
setting.extra_values = {categories: categories}
setting.save

l_event     = create_cms_layout c_site, 'event-calendar', 'イベント'

n_list  = create_cms_node c_content, calendar, 130, nil, l_event, 'GpCalendar::Event', 'event_list', 'イベント一覧', nil
n_event = create_cms_node c_content, calendar, 140, nil, l_event, 'GpCalendar::CalendarStyledEvent', 'calendar', 'イベントカレンダー', nil
n_today = create_cms_node c_content, calendar, 150, nil, l_event, 'GpCalendar::TodaysEvent', 'todays_event', '今日のイベント', nil

## ---------------------------------------------------------
## cms/pieces
key = create_cms_piece c_site, calendar, 'GpCalendar::DailyLink', 'calendar', 'イベントカレンダー', 'イベントカレンダー'
key.in_settings = {target_node_id: n_list.id}
key.save

create_cms_piece c_site,  calendar, 'GpCalendar::NearFutureEvent', 'todays-event', '本日・明日のイベント'
create_cms_piece c_event, calendar, 'GpCalendar::NearFutureEvent', 'todays_event', '本日と明日のイベント'
