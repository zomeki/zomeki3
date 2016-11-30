class InsertListStylesToGpCalendarContentSettings < ActiveRecord::Migration[5.0]
  def change
    calendars = GpCalendar::Content::Event.all
    calendars.each do |calendar|
      GpCalendar::Content::Setting.where(content_id: calendar.id, name: 'list_style')
        .update_all(value: nil)
      defalut_table_style = []
      defalut_table_style << {header: 'サムネイル', data: '@image@'}
      defalut_table_style << {header: '開催日', data: '@hold_date@'}
      defalut_table_style << {header: 'タイトル', data: '@title_link@'}

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
