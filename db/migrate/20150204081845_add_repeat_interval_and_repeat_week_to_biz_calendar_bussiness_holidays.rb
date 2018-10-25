class AddRepeatIntervalAndRepeatWeekToBizCalendarBussinessHolidays < ActiveRecord::Migration[4.2]
  def change
    add_column :biz_calendar_bussiness_holidays, :repeat_interval, :integer
    add_column :biz_calendar_bussiness_holidays, :repeat_week, :text
  end
end
