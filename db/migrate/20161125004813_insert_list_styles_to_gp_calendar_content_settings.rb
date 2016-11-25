class InsertListStylesToGpCalendarContentSettings < ActiveRecord::Migration[5.0]
  def change
    calendars = GpCalendar::Content::Event.all
    calendars.each do |calendar|
      defalut_table_style = []
      list_style = calendar.list_style.to_s || '@title_link@'
      defalut_table_style << {header: 'サムネイル', data: '@image@'} if calendar.show_images?
      defalut_table_style << {header: '開催日', data: '@hold_date'}
      defalut_table_style << {header: 'タイトル', data: list_style}

      calendar_list = GpCalendar::Content::Setting.config(calendar, 'calendar_list_style')
      calendar_list.value = list_style
      calendar_list.save

      list = GpCalendar::Content::Setting.config(calendar, 'list_style')
      list.value = defalut_table_style
      list.save

      today_list = GpCalendar::Content::Setting.config(calendar, 'today_list_style')
      today_list.value = defalut_table_style
      today_list.save

      search_list = GpCalendar::Content::Setting.config(calendar, 'search_list_style')
      search_list.value = defalut_table_style
      search_list.save

    end
  end
end
