## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
biz_calendar = create_cms_content c_content, 'BizCalendar::Place', '業務カレンダー', 'biz_calendar'

l_col1 = Cms::Layout.where(name: 'col-1').first
create_cms_node c_content, biz_calendar, 200, nil, l_col1, 'BizCalendar::Place', 'holiday', '休日カレンダー', nil

[
  {id: 'month_number', value: '2'},
  {id: 'show_month_number', value: '2'},
].each do |conf|
  item = BizCalendar::Content::Setting.config(biz_calendar, conf[:id])
  item.value = conf[:value]
  item.extra_values = conf[:extra_values] if conf[:extra_values]
  item.save
end

content = BizCalendar::Content::Place.first

type = content.types.create title: '休日', name: 'kyujitsu'

place = content.places.create state: 'public', url: 'city',
  title: 'ぞめき市役所', business_hours_state: 'hidden', business_holiday_state: 'hidden'

place.holidays.create type_id: type.id, state: 'public',
  repeat_type: 'saturdays', repeat_interval: 1, end_type: 0,
  start_date: "#{Time.now.year}-04-01"



