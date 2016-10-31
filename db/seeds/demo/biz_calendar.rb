## ---------------------------------------------------------
## cms/concepts

c_site  = Cms::Concept.find(1)
c_top   = Cms::Concept.where(name: 'トップページ').first
c_content = Cms::Concept.where(name: 'コンテンツ').first

## ---------------------------------------------------------
## cms/contents
biz_calendar = create_cms_content c_content, 'BizCalendar::Place', '業務カレンダー', 'biz_calendar'

l_col1 = Cms::Layout.where(name: 'col-1').first
create_cms_content_node biz_calendar, l_col1, 'BizCalendar::Place', 'holiday', '休日カレンダー'

