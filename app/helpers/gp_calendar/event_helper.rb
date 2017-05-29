module GpCalendar::EventHelper
  def event_replace(event, date, list_style)
    GpCalendar::Public::EventFormatService.new(event, date).format(list_style, mobile: Page.mobile?)
  end

  def event_table_replace(event, date, table_style, date_style)
    GpCalendar::Public::EventFormatService.new(event, date).format_table(table_style, date_style, mobile: Page.mobile?)
  end
end
